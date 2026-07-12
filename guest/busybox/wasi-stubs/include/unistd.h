/* OS-MOAP unistd.h wrapper: declare the process-world functions wasi-libc omits
 * but libwasicompat provides (correct prototypes prevent wasm signature traps). */
#ifndef _OSD_UNISTD_WRAP_H
#define _OSD_UNISTD_WRAP_H
#include_next <unistd.h>
#ifdef __cplusplus
extern "C" {
#endif
int dup(int fd);
int dup2(int oldfd, int newfd);
int execl(const char *path, const char *arg, ...);
int execv(const char *path, char *const argv[]);
int execvp(const char *file, char *const argv[]);
int execve(const char *path, char *const argv[], char *const envp[]);
pid_t fork(void);
char *getlogin(void);
int getdtablesize(void);
int pipe(int fds[2]);
pid_t setsid(void);
pid_t setpgrp(void);
pid_t getpgrp(void);
int getpgid(pid_t pid);
int getgroups(int size, gid_t *list);
char *ttyname(int fd);
int tcsetpgrp(int fd, pid_t pgrp);
pid_t tcgetpgrp(int fd);
int setuid(uid_t u);
int seteuid(uid_t u);
int setgid(gid_t g);
int setegid(gid_t g);
int setreuid(uid_t r, uid_t e);
int setregid(gid_t r, gid_t e);
#ifdef __cplusplus
}
#endif
#endif
