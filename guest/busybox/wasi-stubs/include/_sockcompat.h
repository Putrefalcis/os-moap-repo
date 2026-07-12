#ifndef __ASSEMBLER__
#ifndef _OSMOAP_SOCKCOMPAT_H
#define _OSMOAP_SOCKCOMPAT_H
#ifndef SOCK_RAW
#define SOCK_RAW 3
#endif
#ifndef SOCK_RDM
#define SOCK_RDM 4
#endif
#ifndef SOCK_SEQPACKET
#define SOCK_SEQPACKET 5
#endif
#ifndef SO_REUSEADDR
#define SO_REUSEADDR 2
#ifndef SO_BROADCAST
#define SO_BROADCAST 6
#endif
#ifndef SO_KEEPALIVE
#define SO_KEEPALIVE 9
#endif
#ifndef AI_PASSIVE
#define AI_PASSIVE 1
#endif
#ifndef AI_CANONNAME
#define AI_CANONNAME 2
#endif
#ifndef AI_NUMERICHOST
#define AI_NUMERICHOST 4
#endif
#ifndef AI_NUMERICSERV
#define AI_NUMERICSERV 1024
#endif
#ifndef NI_NUMERICHOST
#define NI_NUMERICHOST 1
#endif
#ifndef NI_NUMERICSERV
#define NI_NUMERICSERV 2
#endif
#ifndef NI_NAMEREQD
#define NI_NAMEREQD 8
#endif
struct sockaddr; typedef unsigned socklen_t;
int getsockname(int, struct sockaddr *, socklen_t *);
int getpeername(int, struct sockaddr *, socklen_t *);
#endif
#endif
#endif
