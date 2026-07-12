/* OS-MOAP: force-included so BusyBox gets wasi headers it gates away on non-Linux,
   plus symbols genuinely missing or feature-gated in wasi-libc. C only. */
#ifndef __ASSEMBLER__
#ifndef _OSMOAP_BBCOMPAT_H
#define _OSMOAP_BBCOMPAT_H
#include <sys/resource.h>
#include <fcntl.h>
#include <signal.h>
#ifndef F_DUPFD
#define F_DUPFD 0
#endif
#ifndef SA_RESTART
#define SA_RESTART 0x10000000
#endif
#ifndef SIG_BLOCK
#define SIG_BLOCK 0
#define SIG_UNBLOCK 1
#define SIG_SETMASK 2
#endif
#ifndef RLIM_INFINITY
typedef unsigned long rlim_t;
struct rlimit { rlim_t rlim_cur, rlim_max; };
#define RLIM_INFINITY (~0UL)
#define RLIMIT_CPU 0
#define RLIMIT_FSIZE 1
#define RLIMIT_DATA 2
#define RLIMIT_STACK 3
#define RLIMIT_CORE 4
#define RLIMIT_NOFILE 7
#define RLIMIT_AS 9
static inline int getrlimit(int r, struct rlimit *l){ (void)r; if(l){l->rlim_cur=RLIM_INFINITY;l->rlim_max=RLIM_INFINITY;} return 0; }
static inline int setrlimit(int r, const struct rlimit *l){ (void)r;(void)l; return 0; }
#endif

/* WASI has no sigaction/sigset ops. Minimal in-process shim: handlers never fire
   (single-process wasm; Ctrl-C is delivered from the browser out-of-band). */
#ifndef _OSD_SIG_SHIM
#define _OSD_SIG_SHIM
/* sigset_t already provided by wasi bits/alltypes.h */
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

extern int h_errno;
#endif
#endif
