#ifndef _OSMOAP_STATFS_H
#define _OSMOAP_STATFS_H
#include <sys/types.h>
struct statfs { unsigned long f_type,f_bsize,f_blocks,f_bfree,f_bavail,f_files,f_ffree,f_namelen; };
static inline int statfs(const char*a,struct statfs*b){return -1;}
static inline int fstatfs(int a,struct statfs*b){return -1;}
#endif
