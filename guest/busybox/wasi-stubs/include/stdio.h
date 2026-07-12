/* OS-MOAP stdio.h wrapper: single-threaded stdio lock no-ops with real prototypes. */
#ifndef _OSD_STDIO_WRAP_H
#define _OSD_STDIO_WRAP_H
#include_next <stdio.h>
#ifdef __cplusplus
extern "C" {
#endif
void flockfile(FILE *f);
void funlockfile(FILE *f);
int ftrylockfile(FILE *f);
#ifdef __cplusplus
}
#endif
#endif
