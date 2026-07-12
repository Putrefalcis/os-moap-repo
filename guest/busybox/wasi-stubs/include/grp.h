#ifndef _OSMOAP_GRP_H
#define _OSMOAP_GRP_H
#include <sys/types.h>
struct group { char *gr_name; char *gr_passwd; gid_t gr_gid; char **gr_mem; };
struct group *getgrnam(const char *name);
struct group *getgrgid(gid_t gid);
int getgrnam_r(const char*,struct group*,char*,size_t,struct group**);
int getgrgid_r(gid_t,struct group*,char*,size_t,struct group**);
void setgrent(void); void endgrent(void); struct group *getgrent(void);
int initgroups(const char*,gid_t);
#endif
