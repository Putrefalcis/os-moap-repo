/* curses-smoke: proves the ncurses <-> OS-MOAP tty-driver contract before nano.
 * Draws a box + message, waits for one key, exits cleanly (tty back to cooked). */
#include <locale.h>
#include <curses.h>

int main(void) {
    setlocale(LC_ALL, "");
    if (initscr() == NULL) return 1;
    raw();
    noecho();
    keypad(stdscr, TRUE);
    box(stdscr, 0, 0);
    mvprintw(2, 4, "OS-MOAP curses smoke: ncurses %s", curses_version());
    mvprintw(4, 4, "press any key to exit");
    refresh();
    int c = getch();
    mvprintw(6, 4, "got key %d", c);
    refresh();
    endwin();
    printf("smoke-exit-clean\n");
    return 0;
}
