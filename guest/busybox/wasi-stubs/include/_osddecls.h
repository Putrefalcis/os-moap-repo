/* OS-MOAP: declarations wasi-libc lacks for functions libwasicompat provides.
 * Injected via -include into package builds (nano etc); busybox has its own path. */
#ifndef OSD_DECLS_H
#define OSD_DECLS_H
int dup(int fd);
int dup2(int oldfd, int newfd);
#endif
