#!/usr/bin/env bash
# zsh 5.9 -> wasm32-wasip1. THE fork/exec surgery port (patches/osmoap-nofork.patch,
# the zsh twin of busybox-ash patches 2/5/6):
#   - externals:   host spawn via osd_spawn; execute()/zexecve() RETURN the status
#                  (osd_nofork) instead of never returning; `exec cmd` still exits.
#   - pipelines:   sequential temp-file threading in execpline2 (a|b: a runs to
#                  completion, b reads the file). zsh's last-stage-in-shell rule
#                  survives, so `... | read v` works.
#   - $(...):      in-process execode with fd 1 -> unlinked temp file; `exit` inside
#                  is contained by an osd_insubst guard in zexit().
#   - still fork:  bg jobs `&`, subshells (...), <(...), =(...), coproc -> zfork()
#                  fails with a clean error (same capability bar as ash).
#   KNOWN LEAKS (documented, ash-family): assignments/cd in $(...) and in non-last
#   pipeline stages persist in the shell; `VAR=x extcmd` exports without restore.
# Also fixes two upstream bitrots (undeclared clktck, jmp_buf array assignment) and
# two wasm indirect-call hook traps (arity-0 fns registered as 2-arg Hookfn).
# ncurses consumer (../ncurses/build.sh first). Static modules: zle, complete,
# compctl, computil, parameter, zutil, terminfo, termcap (rlimits unlinked: no
# rlimits on wasi). Ships /etc/zshenv setting NO_MULTIOS (multios tee needs fork).
# Alpine-tracked (main). Source: sourceforge (zsh.org mirrors age out).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
P="$HERE/.."
ROOT="$P/../.."
SDK="${SDK:-$ROOT/build/wasi-sdk}"
STUBS="$P/../busybox/wasi-stubs/include"
COMPAT="$P/../busybox/wasi-compat"

VER="${OSD_PKG_VER:-5.9}"
TARBALL="$P/zsh-$VER.tar.xz"
case "$VER" in
  5.9) WANT_SHA="9b8d1ecedd5b5e81fbf1918e876752a7dd948e05c1a0dba10ab863842d45acd5" ;;
  *)   WANT_SHA="${OSD_PKG_SHA:-}" ;;
esac
if [ ! -f "$TARBALL" ]; then
  URL="https://downloads.sourceforge.net/project/zsh/zsh/$VER/zsh-$VER.tar.xz"
  echo "fetching $URL"
  curl -fsSL -o "$TARBALL" "$URL"
fi
GOT_SHA="$(sha256sum "$TARBALL" | cut -d' ' -f1)"
if [ -n "$WANT_SHA" ]; then
  [ "$GOT_SHA" = "$WANT_SHA" ] || { echo "FATAL: zsh-$VER sha mismatch: $GOT_SHA"; exit 1; }
else
  echo "WARNING: no sha pin for zsh-$VER -- TOFU via TLS. sha256=$GOT_SHA"
fi
SRC="$P/zsh-upstream"
if [ "$(cat "$SRC/.osd-ver" 2>/dev/null)" != "$VER" ]; then
  rm -rf "$SRC"; mkdir -p "$SRC"
  tar xJf "$TARBALL" -C "$SRC" --strip-components=1
  (cd "$SRC" && patch -p1 < "$HERE/patches/osmoap-nofork.patch")
  echo "$VER" > "$SRC/.osd-ver"
fi
[ -f "$P/ncurses-build/lib/libncursesw.a" ] || { echo "run ../ncurses/build.sh first"; exit 1; }

BUILD="$P/zsh-build"
rm -rf "$BUILD"; mkdir "$BUILD"; cd "$BUILD"
# FLAGS go in CPPFLAGS *and* CPP: configure's preprocessor probes and the
# signames.c header-parsing rule both run bare $(CPP).
# F_*: wasi-libc hides fcntl lock/dup cmds behind __wasilibc_unmodified_upstream
# (F_DUPFD=0 matches __wrap_fcntl's compile-time view; locks fail EINVAL at
# runtime, which zsh's HIST_FCNTL_LOCK handles). FD_CLOEXEC=1 disarms the
# close-SHTTY-before-exec paths (we survive exec now). getrusage=no: wasi's
# struct rusage lacks ru_maxrss (zsh assumes it; times() fallback is fine).
FLAGS="--target=wasm32-wasip1 --sysroot=$SDK/share/wasi-sysroot -I$STUBS -I$P/ncurses-build/include -I$P/ncurses-build/include/ncursesw -D_GNU_SOURCE -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_PROCESS_CLOCKS -D_WASI_EMULATED_GETPID -DF_DUPFD=0 -DF_RDLCK=0 -DF_WRLCK=1 -DF_UNLCK=2 -DF_GETLK=5 -DF_SETLK=6 -DF_SETLKW=7 -DFD_CLOEXEC=1"
../zsh-upstream/configure --host=wasm32-wasip1 --build=x86_64-pc-linux-gnu \
  CC="$SDK/bin/clang" CPP="$SDK/bin/clang -E $FLAGS" CPPFLAGS="$FLAGS" \
  CFLAGS="$FLAGS -O2 -mllvm -wasm-enable-sjlj -Wno-error=implicit-function-declaration" \
  LDFLAGS="-L$P/ncurses-build/lib -L$COMPAT -lsetjmp -lwasi-emulated-signal -lwasi-emulated-process-clocks -lwasi-emulated-getpid -Wl,--wrap,fcntl -Wl,-z,stack-size=1048576" \
  LIBS="-lwasicompat" AR="$SDK/bin/llvm-ar" RANLIB="$SDK/bin/llvm-ranlib" \
  ac_cv_func_getrusage=no ac_cv_func_link=no \
  --disable-dynamic --disable-gdbm --disable-pcre --disable-cap \
  --disable-locale --enable-multibyte --disable-dynamic-nss --with-term-lib=ncursesw
# link=no: wasi has no hardlinks; zsh's symlink-based history locking is gated
# on a link()-having host, and this flips it to open(O_EXCL) locking (works).
# rlimits module: its awk-generated resource tables come out empty on wasi
sed -i 's|name=zsh/rlimits modfile=Src/Builtins/rlimits.mdd link=static auto=yes load=yes|name=zsh/rlimits modfile=Src/Builtins/rlimits.mdd link=no auto=yes load=no|' config.modules
make -j"$(nproc)"
cp Src/zsh "$P/zsh.wasm"
echo "built: $P/zsh.wasm"

STAGE="$HERE/stage"
rm -rf "$STAGE"; mkdir -p "$STAGE/bin" "$STAGE/usr/share/terminfo/x" "$STAGE/etc"
cp "$P/zsh.wasm" "$STAGE/bin/zsh"
cp "$P/terminfo-xterm" "$STAGE/usr/share/terminfo/x/xterm"
cat > "$STAGE/etc/zshenv" <<'EOF'
# OS-MOAP: no fork on this CPU. Multios would need a tee subprocess, so
# `> a > b` is last-wins here (like bash). Everything else that needs a real
# subprocess (&, (...), <(...), =(...), coproc) reports "fork failed".
setopt NO_MULTIOS
EOF
cat > "$STAGE/etc/zshrc" <<'EOF'
# OS-MOAP defaults for interactive zsh (override in ~/.zshrc).
# /home is LinksetData-synced: your prompt history survives reboots.
PS1='%F{cyan}%~%f %# '
HISTFILE=~/.zsh_history
HISTSIZE=200
SAVEHIST=200
setopt SHARE_HISTORY
EOF
python3 "$ROOT/tools/pack_pkg.py" --name zsh --ver "$VER-r${OSD_PKG_REV:-0}" \
  --desc "the Z shell (zle, no-fork wasm port)" --dir "$STAGE"
