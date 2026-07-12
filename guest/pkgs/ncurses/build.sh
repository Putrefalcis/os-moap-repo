#!/usr/bin/env bash
# ncurses 6.5 -> wasm32-wasip1 static lib (libncursesw.a) for OS-MOAP packages.
# Checkpoint (a) of the nano port. Terminfo is NOT compiled in: packages ship the
# compiled terminfo files (usr/share/terminfo/x/*) and ncurses reads them from the
# guest FS at runtime.
#
# Two load-bearing tricks (rediscovered the hard way):
#  - wasi-libc has NO termios.h: use the busybox wasi-stubs header, and put
#    libwasicompat in LIBS so configure's tcgetattr LINK check passes (else term.h
#    falls back to sgtty.h and nothing compiles).
#  - consumers MUST link with -Wl,-z,stack-size=1048576: ncurses' setup frames
#    overflow the default wasm stack, which manifests as "memory access out of
#    bounds" inside __wasilibc_find_abspath (NOT an obvious stack trace).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
PKGS="$HERE/.."
SDK="${SDK:-$PKGS/../../build/wasi-sdk}"
STUBS="$PKGS/../busybox/wasi-stubs/include"
COMPAT="$PKGS/../busybox/wasi-compat"
SRC="$PKGS/ncurses-upstream"
BUILD="$PKGS/ncurses-build"

# Version + source acquisition (see nano/build.sh for the pin/TOFU policy).
NCVER="${OSD_NCURSES_VER:-6.5}"
TARBALL="$PKGS/ncurses-$NCVER.tar.gz"
case "$NCVER" in
  6.5) WANT_SHA="136d91bc269a9a5785e5f9e980bc76ab57428f604ce3e5a5a90cebc767971cc6" ;;
  *)   WANT_SHA="${OSD_NCURSES_SHA:-}" ;;
esac
if [ ! -f "$TARBALL" ]; then
  URL="https://ftpmirror.gnu.org/ncurses/ncurses-$NCVER.tar.gz"
  echo "fetching $URL"
  curl -fsSL -o "$TARBALL" "$URL"
fi
GOT_SHA="$(sha256sum "$TARBALL" | cut -d' ' -f1)"
if [ -n "$WANT_SHA" ]; then
  [ "$GOT_SHA" = "$WANT_SHA" ] || { echo "FATAL: ncurses-$NCVER sha mismatch: $GOT_SHA"; exit 1; }
else
  echo "WARNING: no sha pin for ncurses-$NCVER -- TOFU via TLS. sha256=$GOT_SHA"
fi
if [ "$(cat "$SRC/.osd-ver" 2>/dev/null)" != "$NCVER" ]; then
  rm -rf "$SRC"; mkdir -p "$SRC"
  tar xzf "$TARBALL" -C "$SRC" --strip-components=1
  echo "$NCVER" > "$SRC/.osd-ver"
fi
rm -rf "$BUILD"; mkdir "$BUILD"; cd "$BUILD"
"$SRC/configure" \
  --host=wasm32-wasip1 --build=x86_64-pc-linux-gnu \
  --prefix="$PKGS/sysroot" \
  CC="$SDK/bin/clang" \
  CFLAGS="--target=wasm32-wasip1 --sysroot=$SDK/share/wasi-sysroot -I$STUBS -D_WASI_EMULATED_SIGNAL -O2" \
  LDFLAGS="-L$COMPAT -lwasi-emulated-signal" LIBS="-lwasicompat" \
  AR="$SDK/bin/llvm-ar" RANLIB="$SDK/bin/llvm-ranlib" \
  --enable-widec --without-progs --without-tests --without-cxx --without-cxx-binding \
  --without-manpages --without-shared --without-debug --without-ada \
  --disable-db-install --disable-stripping --without-develop \
  --disable-home-terminfo --with-default-terminfo-dir=/usr/share/terminfo
# term.h is GENERATED (MKterm.h.awk), not created by configure -- build the include
# subdir first so the termios guard has a file to check (on a clean tree it doesn't
# exist post-configure; a stale one from a prior build masked this).
make -C include >/dev/null
grep -q '#if 1 && 1' include/term.h || { echo "FATAL: termios not detected (see header comment)"; exit 1; }
make -j4 libs
echo "built: $BUILD/lib/libncursesw.a"
