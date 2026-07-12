#ifndef _OSMOAP_PWD_H
#define _OSMOAP_PWD_H
#include <sys/types.h>
struct passwd { char *pw_name; char *pw_passwd; uid_t pw_uid; gid_t pw_gid; char *pw_gecos; char *pw_dir; char *pw_shell; };
struct passwd *getpwnam(const char *name);
struct passwd *getpwuid(uid_t uid);
int getpwnam_r(const char*,struct passwd*,char*,size_t,struct passwd**);
int getpwuid_r(uid_t,struct passwd*,char*,size_t,struct passwd**);
void setpwent(void); void endpwent(void); struct passwd *getpwent(void);
#endif
