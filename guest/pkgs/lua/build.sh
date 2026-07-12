#!/usr/bin/env bash
# lua 5.4 -> wasm32-wasip1. Built plain (NOT LUA_USE_POSIX -- io.popen/os.execute
# need a subprocess we don't have). Port notes: sjlj (-mllvm -wasm-enable-sjlj +
# -lsetjmp: lua errors are longjmp), _WASI_EMULATED_SIGNAL (sig_atomic_t in
# lstate.h) + emulated-process-clocks (os.clock); os.tmpname redirected to mkstemp
# (libwasicompat); system()/os.execute stubbed in libwasicompat (returns ENOSYS,
# os.execute() reports failure honestly). Alpine-tracked (main, pkg lua5.4).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
P="$HERE/.."
ROOT="$P/../.."
SDK="${SDK:-$ROOT/build/wasi-sdk}"
STUBS="$P/../busybox/wasi-stubs/include"
COMPAT="$P/../busybox/wasi-compat"

VER="${OSD_PKG_VER:-5.4.8}"
TARBALL="$P/lua-$VER.tar.gz"
case "$VER" in
  5.4.8) WANT_SHA="4f18ddae154e793e46eeab727c59ef1c0c0c2b744e7b94219710d76f530629ae" ;;
  *)     WANT_SHA="${OSD_PKG_SHA:-}" ;;
esac
if [ ! -f "$TARBALL" ]; then
  URL="https://www.lua.org/ftp/lua-$VER.tar.gz"
  echo "fetching $URL"
  curl -fsSL -o "$TARBALL" "$URL"
fi
GOT_SHA="$(sha256sum "$TARBALL" | cut -d' ' -f1)"
if [ -n "$WANT_SHA" ]; then
  [ "$GOT_SHA" = "$WANT_SHA" ] || { echo "FATAL: lua-$VER sha mismatch: $GOT_SHA"; exit 1; }
else
  echo "WARNING: no sha pin for lua-$VER -- TOFU via TLS. sha256=$GOT_SHA"
fi
SRC="$P/lua-upstream"
if [ "$(cat "$SRC/.osd-ver" 2>/dev/null)" != "$VER" ]; then
  rm -rf "$SRC"; mkdir -p "$SRC"
  tar xzf "$TARBALL" -C "$SRC" --strip-components=1
  echo "$VER" > "$SRC/.osd-ver"
fi

cd "$SRC/src"
SRCS=$(ls *.c | grep -vE '^luac\.c$')
"$SDK/bin/clang" --target=wasm32-wasip1 --sysroot="$SDK/share/wasi-sysroot" \
  -I"$STUBS" -D_WASI_EMULATED_SIGNAL \
  -Wno-error=implicit-function-declaration -Wno-implicit-function-declaration \
  '-DLUA_TMPNAMBUFSIZE=32' '-Dlua_tmpnam(b,e)={ strcpy(b,"/tmp/lua_XXXXXX"); e = (mkstemp(b) < 0); }' \
  -O2 -mllvm -wasm-enable-sjlj -o "$P/lua.wasm" $SRCS \
  -L"$COMPAT" -lwasicompat -lsetjmp -lwasi-emulated-signal \
  -lwasi-emulated-process-clocks -lm -Wl,-z,stack-size=1048576
echo "built: $P/lua.wasm"

STAGE="$HERE/stage"
rm -rf "$STAGE"; mkdir -p "$STAGE/bin"
cp "$P/lua.wasm" "$STAGE/bin/lua"
python3 "$ROOT/tools/pack_pkg.py" --name lua --ver "$VER-r${OSD_PKG_REV:-0}" \
  --desc "Lua 5.4 interpreter (no io.popen/os.execute)" --dir "$STAGE"
