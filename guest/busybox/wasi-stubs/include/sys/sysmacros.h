#ifndef _OSMOAP_SYSMACROS_H
#define _OSMOAP_SYSMACROS_H
#define major(x) ((int)(((x)>>8)&0xff))
#define minor(x) ((int)((x)&0xff))
#define makedev(a,b) ((((a)&0xff)<<8)|((b)&0xff))
#endif
