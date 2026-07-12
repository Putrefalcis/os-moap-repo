#!/usr/bin/env bash
# GNU nano 8.6 -> wasm32-wasip1 for OS-MOAP (checkpoints c/d of the editor port).
# Needs: ncurses built first (../ncurses/build.sh), nano-8.6 extracted to
# ../nano-upstream. Output: ../nano.wasm (~1.2MB).
#
# Load-bearing configure seeds (gnulib cross-compile guesses default to "replace",
# and every replacement here is broken on wasm):
#   dup2/fcntl/getdtablesize/sigaction/sigprocmask/sigset_t: provided by
#     libwasicompat + the wasi-stubs signal.h wrapper -- seed checks to yes.
#   gl_cv_func_re_compile_pattern_working=yes: WITHOUT this gnulib compiles its
#     glibc-derived regex which dies "Memory exhausted" at nano startup; wasi-libc's
#     musl regex works (verified).
#   -DF_DUPFD=4090: wasi has no F_DUPFD; gnulib's fallback (1) collides with wasi's
#     F_GETFD (1) -> duplicate case labels in rpl_fcntl.
#   -Wl,-z,stack-size=1048576: ncurses frames overflow the default wasm stack.
# Runtime contract (host side): honest poll_oneoff (shim.mjs) -- ncursesw peeks with
# timed polls after every byte; a poll that lies "ready" makes nano eat keystrokes.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
P="$HERE/.."
SDK="${SDK:-$P/../../build/wasi-sdk}"
STUBS="$P/../busybox/wasi-stubs/include"
COMPAT="$P/../busybox/wasi-compat"
SRC="$P/nano-upstream"
BUILD="$P/nano-build"

# Version + source acquisition (CI tracker sets OSD_PKG_VER on an Alpine bump).
# Supply-chain pins: known versions verify against the table; an unknown version
# verifies against OSD_PKG_SHA if set, else trusts TLS to the canonical host and
# PRINTS the sha (it lands in the tracker's publish commit -- the audit trail).
VER="${OSD_PKG_VER:-8.6}"
TARBALL="$P/nano-$VER.tar.xz"
[ "$VER" = 8.6 ] && [ -f "$P/nano.tar.xz" ] && TARBALL="$P/nano.tar.xz"  # vendored name
case "$VER" in
  8.6) WANT_SHA="f7abfbf0eed5f573ab51bd77a458f32d82f9859c55e9689f819d96fe1437a619" ;;
  *)   WANT_SHA="${OSD_PKG_SHA:-}" ;;
esac
if [ ! -f "$TARBALL" ]; then
  URL="https://www.nano-editor.org/dist/v${VER%%.*}/nano-$VER.tar.xz"
  echo "fetching $URL"
  curl -fsSL -o "$TARBALL" "$URL"
fi
GOT_SHA="$(sha256sum "$TARBALL" | cut -d' ' -f1)"
if [ -n "$WANT_SHA" ]; then
  [ "$GOT_SHA" = "$WANT_SHA" ] || { echo "FATAL: nano-$VER sha mismatch: $GOT_SHA"; exit 1; }
else
  echo "WARNING: no sha pin for nano-$VER -- TOFU via TLS. sha256=$GOT_SHA"
fi
if [ "$(cat "$SRC/.osd-ver" 2>/dev/null)" != "$VER" ]; then
  rm -rf "$SRC"; mkdir -p "$SRC"
  tar xJf "$TARBALL" -C "$SRC" --strip-components=1
  echo "$VER" > "$SRC/.osd-ver"
fi
[ -f "$P/ncurses-build/lib/libncursesw.a" ] || { echo "run ../ncurses/build.sh first"; exit 1; }
rm -rf "$BUILD"; mkdir "$BUILD"; cd "$BUILD"
"$SRC/configure" \
  --host=wasm32-wasip1 --build=x86_64-pc-linux-gnu \
  CC="$SDK/bin/clang" \
  CFLAGS="--target=wasm32-wasip1 --sysroot=$SDK/share/wasi-sysroot -I$STUBS -D_GNU_SOURCE -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_GETPID -D_WASI_EMULATED_PROCESS_CLOCKS -DF_DUPFD=4090 -DP_tmpdir=\\\"/tmp\\\" -O2 -Wno-implicit-function-declaration -Wno-error=implicit-function-declaration" \
  LDFLAGS="-L$COMPAT -L$P/ncurses-build/lib -lwasi-emulated-signal -lwasi-emulated-getpid -lwasi-emulated-process-clocks -Wl,-z,stack-size=1048576" \
  LIBS="-lwasicompat" \
  AR="$SDK/bin/llvm-ar" RANLIB="$SDK/bin/llvm-ranlib" \
  NCURSESW_CFLAGS="-I$P/ncurses-build/include -I$P/ncurses-build/include/ncursesw" \
  NCURSESW_LIBS="$P/ncurses-build/lib/libncursesw.a" \
  gl_cv_func_dup2_works=yes ac_cv_func_dup2=yes \
  gl_cv_func_fcntl_f_dupfd_works=yes gl_cv_func_fcntl_f_dupfd_cloexec=yes ac_cv_func_fcntl=yes \
  ac_cv_func_getdtablesize=yes ac_cv_have_decl_getdtablesize=yes \
  ac_cv_func_sigaction=yes ac_cv_func_sigprocmask=yes \
  gl_cv_type_sigset_t=yes ac_cv_type_sigset_t=yes \
  gl_cv_func_re_compile_pattern_working=yes \
  --disable-speller --disable-mouse --disable-libmagic --enable-utf8
make -j4
cp src/nano "$P/nano.wasm"
echo "built: $P/nano.wasm"
