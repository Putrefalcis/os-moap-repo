/* OS-MOAP: WASI compatibility shims for BusyBox. All WEAK so wasi-libc's own
   definitions win where they exist; these only fill genuine gaps. Single-process
   wasm: fixed pseudo-user (uid/gid 1000, "user"), no real process hierarchy or ttys.
   fork/exec never run — BusyBox uses in-process NOFORK applet dispatch. */
#include <sys/types.h>
#include <errno.h>
#include <stdio.h>
#include <time.h>
#include <string.h>
#include <unistd.h>
#include <pwd.h>
#include <grp.h>
#include <termios.h>

#define WEAK __attribute__((weak))

WEAK uid_t getuid(void)  { return 1000; }
WEAK uid_t geteuid(void) { return 1000; }
WEAK gid_t getgid(void)  { return 1000; }
WEAK gid_t getegid(void) { return 1000; }
WEAK pid_t getppid(void) { return 1; }
WEAK pid_t getpgrp(void) { return 1000; }
WEAK pid_t setsid(void)  { return 1000; }
WEAK int getpgid(pid_t p) { (void)p; return 1000; }
WEAK mode_t umask(mode_t m) { (void)m; return 022; }

/* termios: no kernel tty -- the PAGE is the tty driver. tcgetattr pretends the tty
 * starts in cooked mode (ICANON|ECHO); tcsetattr forwards raw/cooked to the host so
 * the page's line discipline can switch: lineedit raws the tty while editing, restores
 * cooked before ash runs the command -- exactly the kernel dispatch, minus the kernel.
 * In cooked mode the page echoes, line-buffers, and turns ^C into one-shot EOF. */
__attribute__((import_module("env"), import_name("__osd_tty_mode")))
void __osd_tty_mode(int raw);
/* tcgetattr must report the CURRENT mode, not a constant: programs that
 * get-modify-set unrelated flags (nano's flow-control tweak) would otherwise
 * re-impose a fake ICANON and knock the tty back to cooked mid-session. */
static tcflag_t osd_tty_lflag = ICANON | ECHO;
WEAK int tcgetattr(int fd, struct termios *t) {
    (void)fd;
    if (t) { memset(t, 0, sizeof *t); t->c_lflag = osd_tty_lflag; t->c_cc[VMIN] = 1; }
    return 0;
}
WEAK int tcsetattr(int fd, int a, const struct termios *t) {
    (void)a;
    /* fd <= 2: ncurses sets modes on the OUTPUT fd (fd 1), ash's lineedit on fd 0 --
     * they are the same tty here, so any std fd drives the page's line discipline */
    if (fd >= 0 && fd <= 2 && t) {
        osd_tty_lflag = t->c_lflag;
        __osd_tty_mode(!(t->c_lflag & ICANON));
    }
    return 0;
}
WEAK int tcflush(int fd, int q) { (void)fd;(void)q; return 0; }
WEAK int tcdrain(int fd) { (void)fd; return 0; }
/* cfmakeraw: the REAL flag surgery (was a no-op stub -- doom's get-cfmakeraw-set
 * left ICANON|ECHO intact, so the tty never went raw for anyone relying on it;
 * ncurses never noticed because it clears the flags manually). */
WEAK void cfmakeraw(struct termios *t) {
    if (!t) return;
    t->c_iflag &= ~(IGNBRK | BRKINT | PARMRK | ISTRIP | INLCR | IGNCR | ICRNL | IXON);
    t->c_oflag &= ~OPOST;
    t->c_lflag &= ~(ECHO | ECHONL | ICANON | ISIG | IEXTEN);
    t->c_cflag &= ~(CSIZE | PARENB);
    t->c_cflag |= CS8;
    t->c_cc[VMIN] = 1;
    t->c_cc[VTIME] = 0;
}
WEAK speed_t cfgetispeed(const struct termios *t) { (void)t; return 0; }
WEAK speed_t cfgetospeed(const struct termios *t) { (void)t; return 0; }
WEAK int cfsetispeed(struct termios *t, speed_t s) { (void)t;(void)s; return 0; }
WEAK int cfsetospeed(struct termios *t, speed_t s) { (void)t;(void)s; return 0; }
WEAK int cfsetspeed(struct termios *t, speed_t s) { (void)t;(void)s; return 0; }

/* signals: no delivery in single-process wasm; Ctrl-C comes from the browser */
WEAK int sigsuspend(const void *m) { (void)m; errno = EINTR; return -1; }

/* process: fork/exec/wait unused (NOFORK dispatch); resolve cleanly */
WEAK pid_t waitpid(pid_t p, int *s, int o) { (void)p;(void)o; if(s)*s=0; errno=ECHILD; return -1; }
WEAK pid_t wait(int *s) { if(s)*s=0; errno=ECHILD; return -1; }
WEAK int pipe(int fds[2]) { (void)fds; errno=ENOSYS; return -1; }

/* user/group db: one fixed entry */
static struct passwd g_pw = { "user","x",1000,1000,"OS-MOAP user","/home/user","/bin/sh" };
static struct group  g_gr = { "user","x",1000, 0 };
WEAK struct passwd *getpwnam(const char *n) { return (n && !strcmp(n,"user")) ? &g_pw : (struct passwd*)0; }
WEAK struct passwd *getpwuid(uid_t u) { return u==1000 ? &g_pw : (struct passwd*)0; }
WEAK struct group  *getgrnam(const char *n) { return (n && !strcmp(n,"user")) ? &g_gr : (struct group*)0; }
WEAK struct group  *getgrgid(gid_t g) { return g==1000 ? &g_gr : (struct group*)0; }
WEAK void setpwent(void) {} WEAK void endpwent(void) {} WEAK struct passwd *getpwent(void) { return (struct passwd*)0; }
WEAK void setgrent(void) {} WEAK void endgrent(void) {} WEAK struct group *getgrent(void) { return (struct group*)0; }

WEAK pid_t fork(void) { errno=ENOSYS; return -1; }
WEAK int execve(const char *f, char *const a[], char *const e[]) { (void)f;(void)a;(void)e; errno=ENOSYS; return -1; }
WEAK int getgroups(int n, gid_t *l) { (void)n;(void)l; return 0; }

/* fd duplication: WASI has no dup. The JS shim owns the fd table and implements
   dup by sharing the open-file-description; we reach it via these imports. */
extern int __osd_dup(int fromfd, int minfd)  __attribute__((import_module("env"),import_name("__osd_dup")));
extern int __osd_dup2(int fromfd, int tofd)  __attribute__((import_module("env"),import_name("__osd_dup2")));
extern int __real_fcntl(int fd, int cmd, ...);
int dup2(int o, int n) { return __osd_dup2(o, n); }
int dup(int fd) { return __osd_dup(fd, 0); }
/* --wrap,fcntl: intercept F_DUPFD(_CLOEXEC) -> shim dup; delegate the rest to wasi-libc. */
#include <fcntl.h>
#include <stdarg.h>
#ifndef F_DUPFD
#define F_DUPFD 0
#endif
#ifndef F_DUPFD_CLOEXEC
#define F_DUPFD_CLOEXEC 1030
#endif
int __wrap_fcntl(int fd, int cmd, ...) {
    va_list ap; va_start(ap, cmd); long arg = va_arg(ap, long); va_end(ap);
    if (cmd == F_DUPFD || cmd == F_DUPFD_CLOEXEC) return __osd_dup(fd, (int)arg);
    return __real_fcntl(fd, cmd, arg);
}


/* temp files + ownership: WASI has no chown; mkstemp via O_EXCL + a counter. */
#include <stdlib.h>
#include <string.h>
WEAK int fchown(int fd, uid_t u, gid_t g) { (void)fd;(void)u;(void)g; return 0; }
WEAK int chown(const char *p, uid_t u, gid_t g) { (void)p;(void)u;(void)g; return 0; }
WEAK int lchown(const char *p, uid_t u, gid_t g) { (void)p;(void)u;(void)g; return 0; }
WEAK int fchmod(int fd, mode_t m) { (void)fd;(void)m; return 0; }
WEAK int chmod(const char *p, mode_t m) { (void)p;(void)m; return 0; }        /* no perms on our FS */
WEAK int fchmodat(int d, const char *p, mode_t m, int f) { (void)d;(void)p;(void)m;(void)f; return 0; }
WEAK int mkstemp(char *tmpl) {
    size_t n = strlen(tmpl); static unsigned seq = 0;
    if (n >= 6) { unsigned v = ++seq; for (int i = 0; i < 6; i++) { tmpl[n-1-i] = '0' + (v % 10); v /= 10; } }
    return open(tmpl, O_RDWR | O_CREAT | O_EXCL, 0600);
}

WEAK int execvp(const char *f, char *const a[]) { (void)f;(void)a; errno=ENOSYS; return -1; }
WEAK int execv(const char *f, char *const a[]) { (void)f;(void)a; errno=ENOSYS; return -1; }
WEAK int clock_settime(int id, const void *t) { (void)id;(void)t; return 0; }
WEAK int h_errno = 0;

/* cp pulls copy_file.c which can copy device/fifo nodes -- no such thing on WASI.
 * ENOSYS makes cp of a special file fail loudly; regular files never reach this. */
WEAK int mknod(const char *p, mode_t m, dev_t d) { (void)p;(void)m;(void)d; errno=ENOSYS; return -1; }
WEAK int mkfifo(const char *p, mode_t m) { (void)p;(void)m; errno=ENOSYS; return -1; }

/* ---- osd_spawn: the host-side "execve" ---------------------------------------
 * The page instantiates the target as a fresh wasm instance sharing our FS and
 * stdio, runs it to completion (we stay suspended), and returns its exit status
 * (>= 0) or a negated wasi errno (< 0). argv/env travel as flat NUL-separated
 * buffers, each list terminated by a trailing NUL. */
__attribute__((import_module("env"), import_name("__osd_spawn")))
int __osd_spawn(const char *path, int path_len,
                const char *argv_flat, int argv_len,
                const char *env_flat, int env_len);

static int osd_flatten(char *const list[], char **out) {
    int i, n = 0;
    char *buf, *w;
    for (i = 0; list && list[i]; i++) n += strlen(list[i]) + 1;
    if (n == 0) { *out = 0; return 0; }
    buf = malloc(n);
    if (!buf) { *out = 0; return -1; }
    w = buf;
    for (i = 0; list[i]; i++) { size_t l = strlen(list[i]) + 1; memcpy(w, list[i], l); w += l; }
    *out = buf;
    return n;
}

int osd_spawn(const char *path, char *const argv[], char *const envp[]) {
    char *af, *ef;
    char abs[1024];
    int al, el, st;
    /* the host has no per-instance cwd -- resolve relative paths here, where a
     * kernel's execve would (wasi-libc getcwd tracks the shell's chdir) */
    if (path[0] != '/') {
        char cwd[900];
        if (getcwd(cwd, sizeof cwd) && strlen(cwd) + strlen(path) + 2 < sizeof abs) {
            snprintf(abs, sizeof abs, "%s/%s", cwd, path);
            path = abs;
        }
    }
    al = osd_flatten(argv, &af);
    el = osd_flatten(envp, &ef);
    if (al < 0 || el < 0) { free(af); free(ef); errno = ENOMEM; return -1; }
    st = __osd_spawn(path, strlen(path), af, al, ef, el);
    free(af); free(ef);
    if (st < 0) { errno = -st; return -1; }
    return st;   /* child exit status */
}

/* gnulib (nano) probes the fd-table size; our JS fd table grows on demand */
WEAK int getdtablesize(void) { return 256; }

/* nano's remaining process-world edges: no processes to exec/signal, one user,
 * single-threaded stdio. All fail gracefully or no-op. */
WEAK int execl(const char *p, const char *a, ...) { (void)p;(void)a; errno=ENOSYS; return -1; }
WEAK int kill(pid_t pid, int sig) { (void)pid;(void)sig; errno=ENOSYS; return -1; }
WEAK char *getlogin(void) { return (char *)"user"; }
WEAK void flockfile(FILE *f) { (void)f; }
WEAK void funlockfile(FILE *f) { (void)f; }
WEAK int ftrylockfile(FILE *f) { (void)f; return 0; }

/* ---- apk host bridges: package index + card fetch live on the PAGE ------------- */
__attribute__((import_module("env"), import_name("__osd_pkg_index")))
int __osd_pkg_index(char *buf, int len, int force);
__attribute__((import_module("env"), import_name("__osd_pkg_fetch")))
int __osd_pkg_fetch(const char *name, int name_len, const char *dest, int dest_len);

int osd_pkg_index(char *buf, int len, int force) {
    int n = __osd_pkg_index(buf, len, force);
    if (n < 0) { errno = -n; return -1; }
    return n;
}
int osd_pkg_fetch(const char *name, const char *dest) {
    int r = __osd_pkg_fetch(name, strlen(name), dest, strlen(dest));
    if (r < 0) { errno = -r; return -1; }
    return 0;
}

/* Children (and packages like nano) start at '/', but ash exports PWD and wasi-libc
 * has a userspace chdir -- honor it so relative paths behave like a real exec'd
 * process. Runs before main in every binary that links libwasicompat. */
__attribute__((constructor)) static void osd_cwd_init(void) {
    const char *p = getenv("PWD");
    if (p && p[0] == '/') chdir(p);
}

/* tmpfile: wasi-libc has none. mkstemp + immediate unlink -- our JS FS keeps the
 * open node alive after unlink (fd holds the object), matching POSIX semantics.
 * First consumer: figlet's zipio (compressed-font path). */
FILE *tmpfile(void) {
    char path[] = "/tmp/tmpfXXXXXX";
    int fd = mkstemp(path);
    if (fd < 0) return NULL;
    unlink(path);
    return fdopen(fd, "w+b");
}

/* system(): no subprocesses on wasi. Report "no shell" for cmd==NULL and a failure
 * exit for any command -- os.execute()/similar then degrade honestly. (First
 * consumers: lua's os.execute, various configure probes.) */
int system(const char *cmd) {
    if (!cmd) return 0;   /* "is a shell available?" -> no */
    errno = ENOSYS;
    return -1;
}

/* pclose: wasi-libc oddly ships a popen symbol but no pclose, so programs whose
 * popen paths are compiled out can still reference pclose from shared cleanup
 * code (first consumer: less's close_pipe). Nothing can have been popen'd. */
int pclose(FILE *f) {
    (void)f;
    errno = ENOSYS;
    return -1;
}

/* set*uid/gid family: one pseudo-user (1000/1000), nothing to change. Setting
 * to the current id succeeds (no-op); anything else is EPERM like an unprivileged
 * process. (First consumer: zsh's PRIVILEGED-option plumbing, which insists a
 * uid-change mechanism exists at compile time.) */
WEAK int setuid(uid_t u)  { if (u == 1000) return 0; errno = EPERM; return -1; }
WEAK int seteuid(uid_t u) { if (u == 1000) return 0; errno = EPERM; return -1; }
WEAK int setgid(gid_t g)  { if (g == 1000) return 0; errno = EPERM; return -1; }
WEAK int setegid(gid_t g) { if (g == 1000) return 0; errno = EPERM; return -1; }
WEAK int setreuid(uid_t r, uid_t e) {
    if ((r == (uid_t)-1 || r == 1000) && (e == (uid_t)-1 || e == 1000)) return 0;
    errno = EPERM; return -1;
}
WEAK int setregid(gid_t r, gid_t e) {
    if ((r == (gid_t)-1 || r == 1000) && (e == (gid_t)-1 || e == 1000)) return 0;
    errno = EPERM; return -1;
}

/* ttyname: no /dev in the guest FS, so the name is honest but unopenable --
 * callers that open() it fall through to their dup(0) fallbacks (zsh init_io,
 * less open_tty). isatty() is the real signal here. */
WEAK char *ttyname(int fd) { return isatty(fd) ? (char *)"/dev/tty" : NULL; }

/* tty process group: one process group, and it owns the one terminal. Setting
 * it "succeeds", reading it returns our own pgrp -- job-control code (zsh
 * attachtty/gettygrp) then correctly believes it's the foreground group. */
WEAK int tcsetpgrp(int fd, pid_t pgrp) { (void)fd; (void)pgrp; return 0; }
WEAK pid_t tcgetpgrp(int fd) { (void)fd; return getpgrp(); }
WEAK pid_t setpgrp(void) { return 0; }
WEAK int setpgid(pid_t p, pid_t g) { (void)p; (void)g; return 0; }  /* one pgroup */

/* alarm: nothing can deliver SIGALRM (no async signals) -- arming a timer is a
 * silent no-op (zsh TMOUT / zle timeouts simply never fire). */
WEAK unsigned alarm(unsigned s) { (void)s; return 0; }

/* pause: waiting for a signal would deadlock a single-threaded wasm world.
 * Pretend one arrived immediately -- callers loop and re-check their state. */
WEAK int pause(void) { errno = EINTR; return -1; }

/* mktemp: name-only variant of mkstemp (callers open with O_EXCL themselves).
 * Wall-clock nanoseconds mixed in so separate instances (parent vs spawned
 * child, each with fresh statics) don't mint the same name. */
WEAK char *mktemp(char *tmpl) {
    size_t n = strlen(tmpl); static unsigned seq = 0;
    struct timespec ts = {0, 0};
    clock_gettime(CLOCK_REALTIME, &ts);
    unsigned v = (unsigned)ts.tv_nsec ^ (++seq * 2654435761u);
    if (n >= 6) for (int i = 0; i < 6; i++) { tmpl[n-1-i] = 'a' + (v % 26); v /= 26; }
    return tmpl;
}
