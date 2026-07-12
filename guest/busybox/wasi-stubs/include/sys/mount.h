#ifndef _OSMOAP_MOUNT_H
#define _OSMOAP_MOUNT_H
#define MS_RDONLY 1
static inline int mount(const char*a,const char*b,const char*c,unsigned long d,const void*e){return -1;}
static inline int umount(const char*a){return -1;}
static inline int umount2(const char*a,int b){return -1;}
#endif
