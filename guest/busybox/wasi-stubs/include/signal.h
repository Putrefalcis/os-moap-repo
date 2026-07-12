/* OS-MOAP signal.h wrapper: wasi-libc ships signal numbers + emulated raise/signal
 * but NO sigaction (that block is compiled out upstream). Packages built against
 * these stubs (nano, ncurses consumers) get the same minimal no-op shim busybox
 * uses via _bbcompat.h: handlers never fire — single-process wasm, ^C is handled
 * by the page's tty driver out-of-band. Guarded by _OSD_SIG_SHIM so _bbcompat.h
 * (force-included first in busybox builds) and this wrapper never collide. */
#ifndef _OSD_SIGNAL_WRAP_H
#define _OSD_SIGNAL_WRAP_H
#include <__typedef_sigset_t.h>  /* wasi signal.h itself never defines sigset_t;
                             TUs that include nothing else requesting it (sl.c)
                             need this or the shim structs below don't parse */
#include_next <signal.h>

#ifndef _OSD_SIG_SHIM
#define _OSD_SIG_SHIM
struct sigaction {
    void (*sa_handler)(int);
    sigset_t sa_mask;
    int sa_flags;
    void (*sa_sigaction)(int, void *, void *);
};
static inline int sigemptyset(sigset_t *s){ if(s)*s=0; return 0; }
static inline int sigfillset(sigset_t *s){ if(s)*s=~0UL; return 0; }
static inline int sigaddset(sigset_t *s,int n){ if(s)*s|=1UL<<((n)&63); return 0; }
static inline int sigdelset(sigset_t *s,int n){ if(s)*s&=~(1UL<<((n)&63)); return 0; }
static inline int sigismember(const sigset_t *s,int n){ return s?(int)((*s>>((n)&63))&1):0; }
static inline int sigprocmask(int h,const sigset_t *s,sigset_t *o){ (void)h;(void)s; if(o)*o=0; return 0; }
static inline int sigaction(int n,const struct sigaction *a,struct sigaction *o){ (void)n;(void)a; if(o){o->sa_handler=0;o->sa_flags=0;} return 0; }
#endif

#ifndef SA_SIGINFO
#define SA_SIGINFO  4
#endif
#ifndef SA_RESTART
#define SA_RESTART  0x10000000
#endif
#ifndef SA_NODEFER
#define SA_NODEFER  0x40000000
#endif
#ifndef SA_RESETHAND
#define SA_RESETHAND 0x80000000
#endif
#ifndef SIG_BLOCK
#define SIG_BLOCK   0
#define SIG_UNBLOCK 1
#define SIG_SETMASK 2
#endif
#endif
