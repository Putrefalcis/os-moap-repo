#!/usr/bin/env bash
# sl -> wasm32-wasip1. The steam locomotive, in a prim. ncurses consumer (needs
# ../ncurses/build.sh first); ships its own terminfo like nano does (packages are
# self-contained -- no dep resolution). Port note: TUs including <signal.h> alone
# needed the __typedef_sigset_t.h include added to the stubs wrapper.
# Alpine-tracked (community). Source: github.com/mtoyoda/sl.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
P="$HERE/.."
ROOT="$P/../.."
SDK="${SDK:-$ROOT/build/wasi-sdk}"
STUBS="$P/../busybox/wasi-stubs/include"
COMPAT="$P/../busybox/wasi-compat"

VER="${OSD_PKG_VER:-5.02}"
TARBALL="$P/sl-$VER.tar.gz"
case "$VER" in
  5.02) WANT_SHA="1e5996757f879c81f202a18ad8e982195cf51c41727d3fea4af01fdcbbb5563a" ;;
  *)    WANT_SHA="${OSD_PKG_SHA:-}" ;;
esac
if [ ! -f "$TARBALL" ]; then
  URL="https://github.com/mtoyoda/sl/archive/refs/tags/$VER.tar.gz"
  echo "fetching $URL"
  curl -fsSL -o "$TARBALL" "$URL"
fi
GOT_SHA="$(sha256sum "$TARBALL" | cut -d' ' -f1)"
if [ -n "$WANT_SHA" ]; then
  [ "$GOT_SHA" = "$WANT_SHA" ] || { echo "FATAL: sl-$VER sha mismatch: $GOT_SHA"; exit 1; }
else
  echo "WARNING: no sha pin for sl-$VER -- TOFU via TLS. sha256=$GOT_SHA"
fi
SRC="$P/sl-upstream"
if [ "$(cat "$SRC/.osd-ver" 2>/dev/null)" != "$VER" ]; then
  rm -rf "$SRC"; mkdir -p "$SRC"
  tar xzf "$TARBALL" -C "$SRC" --strip-components=1
  echo "$VER" > "$SRC/.osd-ver"
fi
[ -f "$P/ncurses-build/lib/libncursesw.a" ] || { echo "run ../ncurses/build.sh first"; exit 1; }

"$SDK/bin/clang" --target=wasm32-wasip1 --sysroot="$SDK/share/wasi-sysroot" \
  -I"$STUBS" -I"$P/ncurses-build/include" -I"$P/ncurses-build/include/ncursesw" \
  -D_GNU_SOURCE -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_PROCESS_CLOCKS -O2 \
  -o "$P/sl.wasm" "$SRC/sl.c" "$P/ncurses-build/lib/libncursesw.a" \
  -L"$COMPAT" -lwasicompat -lwasi-emulated-signal -lwasi-emulated-process-clocks \
  -Wl,-z,stack-size=1048576
echo "built: $P/sl.wasm"

STAGE="$HERE/stage"
rm -rf "$STAGE"; mkdir -p "$STAGE/bin" "$STAGE/usr/share/terminfo/x"
cp "$P/sl.wasm" "$STAGE/bin/sl"
cp "$P/terminfo-xterm" "$STAGE/usr/share/terminfo/x/xterm"
python3 "$ROOT/tools/pack_pkg.py" --name sl --ver "$VER-r${OSD_PKG_REV:-0}" \
  --desc "cure your bad habit of mistyping ls" --dir "$STAGE"
