/* doomgeneric_osmoap.c -- DOOM in a Second Life prim's terminal.
 *
 * OS-MOAP backend for doomgeneric: renders the 320x200 frame as ANSI
 * truecolor HALF-BLOCKS (upper-half-block glyph, fg = top pixel, bg = bottom
 * pixel -> 2 vertical pixels per terminal cell) into an xterm.js terminal,
 * reads WASD/arrow keys from the raw tty, and keeps time with wasi clocks.
 *
 * Terminal facts this leans on:
 *  - COLUMNS/LINES env (TIOCGWINSZ doesn't exist on wasi; term.js exports them)
 *  - xterm.js SGR truecolor (38;2/48;2), alt screen (?1049), cursor hide
 *  - nanosleep => poll_oneoff => JSPI yield: every sleep hands the browser
 *    event loop a turn, which is what keeps rendering + input flowing
 *  - no key-up events: a key is "held" for DOOM_HOLD_MS after its last byte
 *    (terminal autorepeat refreshes the hold), then a release is synthesized
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>
#include <time.h>
#include <termios.h>
#include <poll.h>

#include "doomgeneric.h"
#include "doomkeys.h"

static int g_cols = 80, g_rows = 24;   /* terminal cells */
static int g_px, g_py;                 /* virtual pixels: cols x rows*2 */
static int *g_xe, *g_ye;               /* sample-rect edges into 320x200 */
static char *g_out;                    /* frame emit buffer */
static uint32_t g_last_ms;             /* last emitted frame */
static int g_throttle_ms = 90;         /* ~11 fps cap (DOOM_FPS_MS env) */

/* ---------------- time ---------------- */

uint32_t DG_GetTicksMs(void)
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (uint32_t)((uint64_t)ts.tv_sec * 1000u + ts.tv_nsec / 1000000u);
}

void DG_SleepMs(uint32_t ms)
{
    struct timespec ts = { ms / 1000, (long)(ms % 1000) * 1000000L };
    nanosleep(&ts, NULL);
}

/* ---------------- keys ---------------- */

#define HELD_MAX 16
static struct { unsigned char key; uint32_t last; } g_held[HELD_MAX];
static int g_nheld;
static unsigned char g_evq[64];        /* pending PRESS events */
static int g_evh, g_evt;
static uint32_t g_hold_ms = 550;       /* covers autorepeat initial delay */

static void ev_push(unsigned char k)
{
    int nt = (g_evt + 1) & 63;
    if (nt != g_evh) { g_evq[g_evt] = k; g_evt = nt; }
}

static void key_touch(unsigned char k, uint32_t now)
{
    int i;
    for (i = 0; i < g_nheld; i++)
	if (g_held[i].key == k) { g_held[i].last = now; return; }
    if (g_nheld < HELD_MAX) {
	g_held[g_nheld].key = k;
	g_held[g_nheld].last = now;
	g_nheld++;
	ev_push(k);
    }
}

static int rd_byte(int timeout_ms)
{
    struct pollfd p = { 0, POLLIN, 0 };
    unsigned char b;
    if (poll(&p, 1, timeout_ms) <= 0) return -1;
    if (read(0, &b, 1) != 1) return -1;
    return b;
}

static unsigned char map_key(int c)
{
    switch (c) {
    case 'w': case 'W': return KEY_UPARROW;
    case 's': case 'S': return KEY_DOWNARROW;
    case 'a': case 'A': return KEY_STRAFE_L;
    case 'd': case 'D': return KEY_STRAFE_R;
    case ' ':           return KEY_FIRE;
    case 'e': case 'E': return KEY_USE;
    case 'r': case 'R': return KEY_RSHIFT;   /* hold to run */
    case '\r': case '\n': return KEY_ENTER;
    case '\t':          return KEY_TAB;      /* automap */
    default:
	if ((c >= '1' && c <= '8') || c == 'y' || c == 'n' || c == 'p')
	    return (unsigned char)c;          /* weapons, prompts, pause */
	return 0;
    }
}

static void pump_input(uint32_t now)
{
    int c;
    while ((c = rd_byte(0)) >= 0) {
	unsigned char k = 0;
	if (c == 0x03)		/* ^C: quit like a terminal program should */
	    exit(0);		/* atexit restores the screen */
	if (c == 0x1b) {
	    int c2 = rd_byte(5);              /* lone ESC vs CSI sequence */
	    if (c2 < 0) k = KEY_ESCAPE;
	    else if (c2 == '[') {
		switch (rd_byte(5)) {
		case 'A': k = KEY_UPARROW;    break;
		case 'B': k = KEY_DOWNARROW;  break;
		case 'C': k = KEY_RIGHTARROW; break;  /* turn */
		case 'D': k = KEY_LEFTARROW;  break;
		default:  k = 0;              break;
		}
	    } else k = map_key(c2);           /* alt+X: treat as X */
	} else
	    k = map_key(c);
	if (k) key_touch(k, now);
    }
}

int DG_GetKey(int *pressed, unsigned char *doomKey)
{
    uint32_t now = DG_GetTicksMs();
    int i;

    pump_input(now);

    if (g_evh != g_evt) {                     /* queued presses first */
	*pressed = 1;
	*doomKey = g_evq[g_evh];
	g_evh = (g_evh + 1) & 63;
	return 1;
    }
    for (i = 0; i < g_nheld; i++) {           /* expired holds -> releases */
	if (now - g_held[i].last > g_hold_ms) {
	    *pressed = 0;
	    *doomKey = g_held[i].key;
	    g_held[i] = g_held[--g_nheld];
	    return 1;
	}
    }
    return 0;
}

/* ---------------- video ---------------- */

static void screen_restore(void)
{
    /* leave alt screen, show cursor, reset colors */
    (void)!write(1, "\x1b[0m\x1b[?25h\x1b[?1049l", 18);
}

void DG_Init(void)
{
    const char *e;
    struct termios t;
    int i;

    if ((e = getenv("COLUMNS")) && atoi(e) > 19) g_cols = atoi(e);
    if ((e = getenv("LINES"))   && atoi(e) > 9)  g_rows = atoi(e);
    if ((e = getenv("DOOM_FPS_MS")) && atoi(e) > 0) g_throttle_ms = atoi(e);
    if ((e = getenv("DOOM_HOLD_MS")) && atoi(e) > 0) g_hold_ms = atoi(e);
    g_px = g_cols;
    g_py = g_rows * 2;

    /* sample-rectangle edges: cell column c covers x in [xe[c], xe[c+1]),
     * half-block pixel row p covers y in [ye[p], ye[p+1]) of the 320x200 */
    g_xe = malloc((g_px + 1) * sizeof(int));
    g_ye = malloc((g_py + 1) * sizeof(int));
    for (i = 0; i <= g_px; i++) g_xe[i] = i * DOOMGENERIC_RESX / g_px;
    for (i = 0; i <= g_py; i++) g_ye[i] = i * DOOMGENERIC_RESY / g_py;

    /* worst case per cell: full SGR + 3-byte glyph (~42B) + row overhead */
    g_out = malloc((size_t)g_cols * g_rows * 48 + g_rows * 8 + 64);

    tcgetattr(0, &t);
    cfmakeraw(&t);
    /* explicit: the page's line discipline keys ONLY on ICANON -- make the
     * intent unmissable whatever a libc's cfmakeraw does */
    t.c_lflag &= ~(ICANON | ECHO | ISIG);
    tcsetattr(0, TCSANOW, &t);
    atexit(screen_restore);
    (void)!write(1, "\x1b[?1049h\x1b[?25l\x1b[2J", 18);
}

static int avg_block(int x0, int x1, int y0, int y1)
{
    /* box-average an XRGB rect of the 320x200 DG_ScreenBuffer */
    int x, y, n = 0;
    unsigned r = 0, g = 0, b = 0;
    for (y = y0; y < y1; y++) {
	const uint32_t *row = DG_ScreenBuffer + (size_t)y * DOOMGENERIC_RESX;
	for (x = x0; x < x1; x++) {
	    uint32_t p = row[x];
	    r += (p >> 16) & 255; g += (p >> 8) & 255; b += p & 255;
	    n++;
	}
    }
    if (!n) return 0;
    return ((r / n) << 16) | ((g / n) << 8) | (b / n);
}

void DG_DrawFrame(void)
{
    uint32_t now = DG_GetTicksMs();
    char *o = g_out;
    int r, c, prev_fg = -1, prev_bg = -1;

    if (now - g_last_ms < (uint32_t)g_throttle_ms) return;
    g_last_ms = now;

    memcpy(o, "\x1b[H", 3); o += 3;
    for (r = 0; r < g_rows; r++) {
	for (c = 0; c < g_cols; c++) {
	    int fg = avg_block(g_xe[c], g_xe[c+1], g_ye[2*r],   g_ye[2*r+1]);
	    int bg = avg_block(g_xe[c], g_xe[c+1], g_ye[2*r+1], g_ye[2*r+2]);
	    if (fg != prev_fg || bg != prev_bg) {
		o += sprintf(o, "\x1b[38;2;%d;%d;%d;48;2;%d;%d;%dm",
			     (fg>>16)&255, (fg>>8)&255, fg&255,
			     (bg>>16)&255, (bg>>8)&255, bg&255);
		prev_fg = fg; prev_bg = bg;
	    }
	    memcpy(o, "\xe2\x96\x80", 3); o += 3;   /* upper half block */
	}
	if (r != g_rows - 1) { memcpy(o, "\r\n", 2); o += 2; }
    }
    (void)!write(1, g_out, o - g_out);
}

void DG_SetWindowTitle(const char *title)
{
    char buf[128];
    int n = snprintf(buf, sizeof buf, "\x1b]0;%s\x07", title);
    if (n > 0) (void)!write(1, buf, n);
}

int main(int argc, char **argv)
{
    doomgeneric_Create(argc, argv);
    for (;;)
	doomgeneric_Tick();
    return 0;
}
