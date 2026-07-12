/* vi: set sw=4 ts=4: */
/*
 * apk — OS-MOAP package manager (apk-style UX over prim-notecard media).
 *
 * Packages are notecards in the prim (pkg-<name>-NNN). The heavy lifting —
 * census, manifest reads, chunk fetch/verify, gunzip — happens on the PAGE via
 * two host bridges (wasi-compat.c): osd_pkg_index() and osd_pkg_fetch(), which
 * deliver a plain-text index and a PLAIN USTAR at a path in the shared FS.
 * This applet extracts the tar (our own deterministic ustar from pack_pkg.py:
 * regular files only, <=100-char names), keeps the database, honors the world.
 *
 *   /etc/apk/world        what the user asked for (PERSISTED via LinksetData)
 *   /lib/apk/db/installed P:/V:/T: stanzas + F:<file> lines (rebuilt each boot)
 *
 * Copyright (C) 2026 OS-MOAP. Licensed under GPLv2, see file LICENSE.
 */
//config:config APK
//config:	bool "apk (OS-MOAP package manager)"
//config:	default n
//config:	help
//config:	Install programs from the prim's package notecards: apk add nano.
//applet:IF_APK(APPLET(apk, BB_DIR_SBIN, BB_SUID_DROP))
//kbuild:lib-$(CONFIG_APK) += apk.o
//usage:#define apk_trivial_usage
//usage:       "add|del|list|info|search|update|upgrade|sync-world [PKG]..."
//usage:#define apk_full_usage "\n\n"
//usage:       "Manage packages from the prim's notecard media + /etc/apk/repositories\n"
//usage:     "\n	add PKG...	fetch + install (records in /etc/apk/world)"
//usage:     "\n	del PKG...	remove files, drop from world"
//usage:     "\n	list		available packages ([installed] marked)"
//usage:     "\n	info PKG	one package's line + state"
//usage:     "\n	search STR	filter the index"
//usage:     "\n	update		refresh the index (cards + web repos)"
//usage:     "\n	upgrade		reinstall world packages whose index version changed"
//usage:     "\n	sync-world	reinstall everything in the world (boot)"

#include "libbb.h"

extern int osd_pkg_index(char *buf, int len, int force);
extern int osd_pkg_fetch(const char *name, const char *dest);

#define WORLD   "/etc/apk/world"
#define DB      "/lib/apk/db/installed"
#define TARTMP  "/tmp/.apk.tar"

static char *read_file_or_empty(const char *path)
{
	char *s = xmalloc_open_read_close(path, NULL);
	return s ? s : xstrdup("");
}

static int in_lines(const char *haystack, const char *name)
{
	const char *p = haystack;
	size_t n = strlen(name);
	while (p && *p) {
		if (strncmp(p, name, n) == 0 && (p[n] == '\n' || p[n] == '\0' || p[n] == ' '))
			return 1;
		p = strchr(p, '\n');
		if (p) p++;
	}
	return 0;
}

static char *get_index(int force)
{
	/* 64K =~ 700 merged index lines; overflow is a loud -ENODATA death, not a
	 * truncation (the host bridge refuses to split a line) */
	char *buf = xmalloc(65536);
	int n = osd_pkg_index(buf, 65535, force);
	if (n < 0)
		bb_perror_msg_and_die("index unavailable");
	buf[n] = '\0';
	return buf;
}

/* index lines are "name ver zb desc..." -- return ver (2nd token) or NULL */
static char *index_ver(const char *ix, const char *name)
{
	size_t n = strlen(name);
	const char *p = ix;
	while (p && *p) {
		if (strncmp(p, name, n) == 0 && p[n] == ' ') {
			const char *v = p + n + 1;
			const char *e = v;
			while (*e && *e != ' ' && *e != '\n') e++;
			return xstrndup(v, e - v);
		}
		p = strchr(p, '\n');
		if (p) p++;
	}
	return NULL;
}

/* installed version: the V: line of the P:<name> stanza, or NULL */
static char *db_ver(const char *db, const char *name)
{
	char *probe = xasprintf("P:%s\nV:", name);
	char *st = strstr(db, probe);
	char *r = NULL;
	if (st) {
		char *v = st + strlen(probe);
		char *e = strchrnul(v, '\n');
		r = xstrndup(v, e - v);
	}
	free(probe);
	return r;
}

/* ---- minimal ustar extraction (our own pack_pkg format: regular files) ---- */
static unsigned oct(const char *p, int len)
{
	unsigned v = 0;
	while (len-- && *p) {
		if (*p >= '0' && *p <= '7') v = v * 8 + (*p - '0');
		p++;
	}
	return v;
}

/* extracts under /, records "F:<path>\n" lines into a growing string.
 * .PKGINFO content is captured separately (not written to /). */
static char *tar_extract(const char *tarpath, char **pkginfo)
{
	int fd = xopen(tarpath, O_RDONLY);
	char hdr[512];
	char *files = xstrdup("");
	*pkginfo = NULL;
	for (;;) {
		if (full_read(fd, hdr, 512) != 512)
			break;
		if (hdr[0] == '\0')
			break;                       /* end-of-archive blocks */
		unsigned size = oct(hdr + 124, 12);
		char name[101];
		safe_strncpy(name, hdr, 101);
		unsigned pad = (512 - (size % 512)) % 512;
		char *data = xmalloc(size + 1);
		if ((unsigned)full_read(fd, data, size) != size)
			bb_error_msg_and_die("truncated tar");
		data[size] = '\0';
		if (pad) lseek(fd, pad, SEEK_CUR);
		if (hdr[156] != '0' && hdr[156] != '\0') {  /* not a regular file */
			free(data);
			continue;
		}
		if (strcmp(name, ".PKGINFO") == 0) {
			*pkginfo = data;
			continue;
		}
		char *abs = xasprintf("/%s", name);
		bb_make_directory(dirname(xstrdup(abs)), -1, FILEUTILS_RECUR);
		int ofd = xopen3(abs, O_WRONLY | O_CREAT | O_TRUNC, 0755);
		xwrite(ofd, data, size);
		close(ofd);
		{
			char *nf = xasprintf("%sF:%s\n", files, abs);
			free(files);
			files = nf;
		}
		free(abs);
		free(data);
	}
	close(fd);
	return files;
}

static void append_file(const char *path, const char *text)
{
	int fd = open(path, O_WRONLY | O_CREAT | O_APPEND, 0644);
	if (fd < 0) {
		bb_make_directory(dirname(xstrdup(path)), -1, FILEUTILS_RECUR);
		fd = xopen3(path, O_WRONLY | O_CREAT | O_APPEND, 0644);
	}
	xwrite_str(fd, text);
	close(fd);
}

static void write_file(const char *path, const char *text)
{
	bb_make_directory(dirname(xstrdup(path)), -1, FILEUTILS_RECUR);
	int fd = xopen3(path, O_WRONLY | O_CREAT | O_TRUNC, 0644);
	xwrite_str(fd, text);
	close(fd);
}

/* find "key = value" in .PKGINFO */
static char *pi_get(const char *pi, const char *key)
{
	const char *p = pi;
	size_t n = strlen(key);
	while (p && *p) {
		if (strncmp(p, key, n) == 0 && p[n] == ' ' && p[n+1] == '=' ) {
			const char *v = p + n + 3;
			const char *e = strchrnul(v, '\n');
			return xstrndup(v, e - v);
		}
		p = strchr(p, '\n');
		if (p) p++;
	}
	return xstrdup("?");
}

/* extract + register an ALREADY-FETCHED tar at TARTMP (upgrade fetches first so a
 * failed download never leaves the old version uninstalled) */
static int install_tar_file(const char *name, int record_world)
{
	char *pkginfo;
	char *files = tar_extract(TARTMP, &pkginfo);
	unlink(TARTMP);
	if (!pkginfo) pkginfo = xstrdup("");
	char *ver = pi_get(pkginfo, "pkgver");
	char *desc = pi_get(pkginfo, "pkgdesc");
	char *stanza = xasprintf("P:%s\nV:%s\nT:%s\n%s\n", name, ver, desc, files);
	append_file(DB, stanza);
	free(stanza); free(ver); free(desc); free(files); free(pkginfo);

	if (record_world) {
		char *w = read_file_or_empty(WORLD);
		if (!in_lines(w, name)) {
			char *line = xasprintf("%s\n", name);
			append_file(WORLD, line);
			free(line);
		}
		free(w);
	}
	printf("OK: %s installed\n", name);
	return 0;
}

static int do_add(const char *name, int record_world)
{
	char *db = read_file_or_empty(DB);
	char *stanza_probe = xasprintf("P:%s\n", name);
	if (strstr(db, stanza_probe)) {
		printf("%s: already installed\n", name);
		free(db); free(stanza_probe);
		return 0;
	}
	free(db); free(stanza_probe);

	printf("(1/1) Installing %s...\n", name);
	fflush_all();
	if (osd_pkg_fetch(name, TARTMP) != 0) {
		bb_perror_msg("%s: fetch failed", name);
		return 1;
	}
	return install_tar_file(name, record_world);
}

static int do_del(const char *name)
{
	char *db = read_file_or_empty(DB);
	char *probe = xasprintf("P:%s\n", name);
	char *st = strstr(db, probe);
	free(probe);
	if (!st) {
		bb_error_msg("%s: not installed", name);
		free(db);
		return 1;
	}
	/* stanza ends at blank line */
	char *end = strstr(st, "\n\n");
	end = end ? end + 2 : st + strlen(st);
	/* unlink every F: file in the stanza */
	char *p = st;
	while (p < end) {
		if (p[0] == 'F' && p[1] == ':') {
			char *nl = strchrnul(p, '\n');
			char *path = xstrndup(p + 2, nl - (p + 2));
			unlink(path);
			free(path);
		}
		p = strchrnul(p, '\n');
		if (*p) p++;
	}
	/* rewrite db without the stanza */
	memmove(st, end, strlen(end) + 1);
	write_file(DB, db);
	free(db);
	/* drop from world */
	char *w = read_file_or_empty(WORLD);
	char *line = xasprintf("%s\n", name);
	char *hit = strstr(w, line);
	if (hit && (hit == w || hit[-1] == '\n')) {
		memmove(hit, hit + strlen(line), strlen(hit + strlen(line)) + 1);
		write_file(WORLD, w);
	}
	free(line); free(w);
	printf("OK: %s removed\n", name);
	return 0;
}

int apk_main(int argc, char **argv) MAIN_EXTERNALLY_VISIBLE;
int apk_main(int argc UNUSED_PARAM, char **argv)
{
	const char *cmd = argv[1];
	if (!cmd)
		bb_show_usage();

	if (strcmp(cmd, "update") == 0) {
		char *ix = get_index(1);
		int n = 0;
		for (char *p = ix; *p; p++) if (*p == '\n') n++;
		printf("OK: %d packages available\n", n);
		free(ix);
		return 0;
	}
	if (strcmp(cmd, "list") == 0 || strcmp(cmd, "search") == 0) {
		const char *filter = argv[2];
		char *ix = get_index(0);
		char *db = read_file_or_empty(DB);
		char *line = strtok(ix, "\n");
		while (line) {
			char nm[64];
			safe_strncpy(nm, line, sizeof(nm));
			char *sp = strchr(nm, ' ');
			if (sp) *sp = '\0';
			if (!filter || strstr(line, filter)) {
				char *probe = xasprintf("P:%s\n", nm);
				printf("%s%s\n", line, strstr(db, probe) ? " [installed]" : "");
				free(probe);
			}
			line = strtok(NULL, "\n");
		}
		free(ix); free(db);
		return 0;
	}
	if (strcmp(cmd, "info") == 0) {
		if (!argv[2]) bb_show_usage();
		char *ix = get_index(0);
		char *line = strtok(ix, "\n");
		while (line) {
			if (strncmp(line, argv[2], strlen(argv[2])) == 0 && line[strlen(argv[2])] == ' ') {
				puts(line);
				free(ix);
				return 0;
			}
			line = strtok(NULL, "\n");
		}
		bb_error_msg("%s: no such package", argv[2]);
		free(ix);
		return 1;
	}
	if (strcmp(cmd, "add") == 0) {
		int world = 1, rc = 0, i = 2;
		if (argv[2] && strcmp(argv[2], "--no-world") == 0) { world = 0; i = 3; }
		if (!argv[i]) bb_show_usage();
		for (; argv[i]; i++)
			rc |= do_add(argv[i], world);
		return rc;
	}
	if (strcmp(cmd, "del") == 0) {
		if (!argv[2]) bb_show_usage();
		int rc = 0;
		for (int i = 2; argv[i]; i++)
			rc |= do_del(argv[i]);
		return rc;
	}
	if (strcmp(cmd, "upgrade") == 0) {
		/* reinstall every world package whose index version DIFFERS from the
		 * installed one (strcmp, not vercmp: the merged index already carries
		 * the best version per name, so "converge to index" is also honest on
		 * a repo rollback). Fetch FIRST -- a dead repo must keep the old files. */
		char *ix = get_index(1);            /* upgrade implies update */
		char *db = read_file_or_empty(DB);
		char *w = read_file_or_empty(WORLD);
		int rc = 0, nup = 0;
		char *line = strtok(w, "\n");       /* w snapshot: do_del rewrites WORLD,
		                                       never this buffer; do_del/install
		                                       don't strtok (sync-world pattern) */
		while (line) {
			if (line[0]) {
				char *iv = index_ver(ix, line);
				char *dv = db_ver(db, line);
				if (iv && dv && iv[0] != '?' && strcmp(iv, dv) != 0) {
					printf("(1/1) Upgrading %s %s -> %s...\n", line, dv, iv);
					fflush_all();
					if (osd_pkg_fetch(line, TARTMP) != 0) {
						bb_perror_msg("%s: fetch failed (old version kept)", line);
						rc = 1;
					} else {
						do_del(line);
						rc |= install_tar_file(line, 1);
						nup++;
					}
				}
				free(iv); free(dv);
			}
			line = strtok(NULL, "\n");
		}
		printf("OK: %d package(s) upgraded\n", nup);
		free(ix); free(db); free(w);
		return rc;
	}
	if (strcmp(cmd, "sync-world") == 0) {
		/* boot: packages don't survive a reboot; rebuild the db by reinstalling
		 * everything the world asks for (world itself is the persisted truth) */
		unlink(DB);
		char *w = read_file_or_empty(WORLD);
		int rc = 0;
		char *line = strtok(w, "\n");
		while (line) {
			if (line[0])
				rc |= do_add(line, 0);
			line = strtok(NULL, "\n");
		}
		free(w);
		return rc;
	}
	bb_show_usage();
}
