# BusyBox 1.36.1 → wasm32-wasip1 source patches (OS-MOAP)

Applied to `guest/busybox/upstream/`. Grep `OS-MOAP` in-tree to find them. Rebuild with
`guest/build.sh`; the working config is `guest/busybox/config-wasi-v0`.

## What works (verified under node + our shim, in Chrome 150, AND in the SL viewer's CEF)
Real BusyBox ash runs as wasm with NO fork. Verified: `echo ls cat pwd grep sort wc head
tail uniq cut tr sed seq env date test printf clear` (+ ash builtins), output/input
redirection (`>` `<`), **pipelines of arbitrary length** (`a | b | c | …`), arithmetic
(`$((…))`), `for` loops, glob expansion, variables, `if`/`test`, multiple redirects in a
row, **command substitution `$(…)` and backticks** (nested, quoted, in pipelines, correct
`$?` semantics — see patch 5). In-viewer PASS 9/9 via `web/term.html?selftest=1` (DESIGN.md).

## Patches

1. **shell/ash.c evalcommand (~10537)** — run EVERY applet in-process, not just NOFORK
   (wasm can't fork): `if (applet_no >= 0 && APPLET_IS_NOFORK(...))` → `if (applet_no >= 0)`.

2. **shell/ash.c evalpipe (~9689)** — replace fork+pipe with SEQUENTIAL stages threaded
   through temp files (`/tmp/.osdpN`), fd 0/1 saved/redirected/restored via the shim's
   working dup2 + fcntl(F_DUPFD). Crucial extra: `clearerr(stdin); fpurge(stdin);
   clearerr(stdout);` before each stage — no fork means stages share libc's stdin/stdout
   FILE*, so a prior stage's EOF/buffer must be dropped or the next stage reads stale EOF.

3. **shell/ash.c redirect (~5886)** — after `dup2_or_raise(newfd, fd)`, if fd is 0/1 do the
   same FILE*-state reset. Without this, `cmd <a; cmd <b` reads EOF on the 2nd command
   (same shared-FILE* root cause as #2, but for plain redirects).

4. **scripts/trylink** — wasm-ld rejects `--start-group`/`--end-group` (guard behind a
   check_cc test → empty) and `--warn-common` (drop from INFO_OPTS).

5. **shell/ash.c evalbackcmd (~6600) + osd_evalbackcmd_inproc (~9215) + expbackq (~6700)**
   — in-process command substitution `$(…)`/backticks (FIXED 2026-07-11, was the top gap).
   The nested tree runs via `osd_evalbackcmd_inproc()`: stdout captured to an unlinked temp
   file (`/tmp/.osdbqN`, N = nesting depth) whose fd is handed to expbackq's read loop;
   `back_exitstatus` comes from `osd_bq_status` (no job to wait for).
   **Actual root cause of the old garble** (earlier suspect `bb_common_bufsiz1` was a RED
   HERRING): ash's expansion machinery is non-reentrant BY DESIGN — un-grabbed expansion
   strings live ABOVE `g_stacknxt`, and globals (`expdest`, `argbackq`, ifs regions) carry
   the outer expansion's state; fork isolation was the design assumption. A nested
   `growstackblock()` realloc MOVED the outer arena block while the outer `expdest` still
   pointed into the freed one (hence the `\xNN` garbage + inner command WORDS leaking into
   output — only the expander touches those). The "empty pipeline" mode was the same class.
   Fix, all inside the helper:
   - swap in a FRESH malloc'd stack arena (`g_stackp/g_stacknxt/sstrend/g_stacknleft`) for
     the nested evaltree; walk-free it afterwards; outer arena untouched → outer `expdest`
     stays valid;
   - save/restore `expdest argbackq ifsfirst ifslastp evalskip skipcount loopnest funcline
     exitstatus savestatus eflag` (so `$(break)` can't skip outer loops, parent `$?` is
     preserved, ifs regions for field splitting survive);
   - catch ALL exceptions like a subshell exit (`setjmp` + `exception_handler` swap, the
     `redirectsafe` idiom): inner `exit N` parks N in `savestatus` — consume it exitshell-
     style; other exceptions → status 2; the outer shell always survives;
   - `fflush_all()` + `clearerr(stdout)` around the fd1 redirect (same shared-FILE*
     discipline as patches 2/3).
   KNOWN semantic leak (no-fork, documented): variable assignments inside `$(…)` persist
   into the parent, as with the sequential pipelines of patch 2.

## Runtime shims — `guest/busybox/wasi-compat/` (weak symbols; wasi-libc wins where present)
Process/user-id (`geteuid getppid …`), termios no-ops, `getpwnam`/`getgrnam` (one pseudo-user),
`mkstemp`, `fchown`/`chown`, `execvp`/`execve`/`fork` ENOSYS, `clock_settime`, `h_errno`.
**dup2 + fcntl(F_DUPFD)** route to the JS shim's fd table via imports `env.__osd_dup`/`__osd_dup2`
(WASI has no dup — the shim shares the open-file-description). Linked as `libwasicompat.a`
(archive, so trylink's multiple link passes don't double-define) + `-Wl,--wrap,fcntl`
+ `-Wl,-u,__main_argc_argv` (clang mangles `int main(int,char**)`; without this the crt's
weak `__main_void` never pulls `main` → `unreachable` at start).

## 6. shell/ash.c — non-applet commands spawn via the host (`__osd_spawn`)

Two hooks (grep `OS-MOAP patch 6`):
- `evalcommand` default case (~10650): CMDNORMAL non-applets no longer reach
  forkshell ("can't fork") — `osd_spawn_command()` (defined above evalcommand)
  resolves argv[0] with the same padvance walk as shellexec's try_PATH, passes
  exported vars via `listvars(VEXPORT,...)` (so `VAR=x cmd` propagates), and calls
  `osd_spawn()` (wasi-compat.c) — the HOST runs the file as a fresh wasm instance
  sharing our FS and live fd 0/1/2 dispositions. Unlike shellexec it RETURNS a
  status (127/126 on failure) instead of raising: no parent process exists to
  absorb an EXEND.
- `tryexec` (~8246): a spawn + `_exit(status)` before the (dead) execve — covers
  the `exec` builtin's replace-the-shell semantics. The applet re-exec branch is
  untouched: its execve fails ENOSYS and falls through to the PATH walk, which
  lands on the /bin/<applet> empty marker → spawn's empty-file rule runs the
  busybox Module with argv unchanged (applet dispatch) — `/bin/ls` and `exec ls`
  work through the same door as real programs.

Host dispatch (web/wasi/spawn.mjs): `\0asm` magic → compile (Module cached by
sha) + run; empty file → busybox Module, argv unchanged; anything else → busybox
Module as `['sh', path, ...]` (hashbang interpreter args ignored in v1). Child
inherits the parent's fd 0/1/2 OPEN FILE DESCRIPTIONS (pipeline temp files, tty,
redirects all compose); the parent stays suspended in the Suspending import for
the child's lifetime (nested JSPI — gated by web/wasi/test-spawn.mjs). Relative
paths are absolutized guest-side in osd_spawn() via getcwd(); a wasi-compat
constructor chdir()s to $PWD in every binary linking libwasicompat.

## 7. NEW APPLET miscutils/apk.c + package/spawn shims (OS-MOAP package manager)

`CONFIG_APK=y` adds the apk applet (add/del/list/info/search/update/sync-world).
Non-busybox-upstream; ships with OS-MOAP. It talks to the PAGE via wasi-compat.c
bridges osd_pkg_index()/osd_pkg_fetch() (→ Suspending shim imports __osd_pkg_index/
__osd_pkg_fetch), extracts our own deterministic ustar (from tools/pack_pkg.py), and
keeps /lib/apk/db/installed + /etc/apk/world. Related runtime shims added to
wasi-compat.c this chapter: osd_spawn (patch 6), getdtablesize/execl/kill/getlogin/
flockfile/ftrylockfile (nano/gnulib edges), chmod/fchmodat no-ops. New wasi-stubs
wrappers: signal.h (sigaction shim + SA_* fallbacks — wasi-libc compiles sigaction
out), unistd.h/stdio.h (true prototypes for the compat functions, preventing wasm
signature traps). config-wasi-v0: CONFIG_APK=y. See DESIGN.md "Chapter 2".
