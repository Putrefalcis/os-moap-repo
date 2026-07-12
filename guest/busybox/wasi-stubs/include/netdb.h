#ifndef _OSMOAP_NETDB_H
#define _OSMOAP_NETDB_H
#include <stdint.h>
struct hostent { char *h_name; char **h_aliases; int h_addrtype; int h_length; char **h_addr_list; };
struct servent { char *s_name; char **s_aliases; int s_port; char *s_proto; };
struct protoent { char *p_name; char **p_aliases; int p_proto; };
struct addrinfo { int ai_flags,ai_family,ai_socktype,ai_protocol; unsigned ai_addrlen; struct sockaddr *ai_addr; char *ai_canonname; struct addrinfo *ai_next; };
static inline struct hostent *gethostbyname(const char *n){(void)n;return 0;}
static inline struct servent *getservbyname(const char *n,const char *p){(void)n;(void)p;return 0;}
static inline struct servent *getservbyport(int p,const char *pr){(void)p;(void)pr;return 0;}
static inline struct protoent *getprotobyname(const char *n){(void)n;return 0;}
static inline int getaddrinfo(const char *a,const char *b,const struct addrinfo *c,struct addrinfo **d){(void)a;(void)b;(void)c;(void)d;return -1;}
static inline void freeaddrinfo(struct addrinfo *a){(void)a;}
static inline const char *gai_strerror(int e){(void)e;return "no network";}
#define NI_MAXHOST 1025
#define NI_MAXSERV 32
static inline const char *hstrerror(int e){(void)e;return "host lookup failed";}
#endif
