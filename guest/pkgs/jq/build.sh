#!/usr/bin/env bash
# jq -> wasm32-wasip1. Built --without-oniguruma (regex fns test/match/capture are
# absent -- everything else works; onig is a future port). Needs the busybox sjlj
# treatment (-mllvm -wasm-enable-sjlj + -lsetjmp: jq's error handling is longjmp)
# and _WASI_EMULATED_SIGNAL (vendor/decNumber raises SIGFPE). Alpine-tracked (main).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
P="$HERE/.."
ROOT="$P/../.."
SDK="${SDK:-$ROOT/build/wasi-sdk}"
STUBS="$P/../busybox/wasi-stubs/include"
COMPAT="$P/../busybox/wasi-compat"

VER="${OSD_PKG_VER:-1.8.2}"
TARBALL="$P/jq-$VER.tar.gz"
case "$VER" in
  1.8.2) WANT_SHA="71b8d6e8f5fe81f6c6d0d110e3892251f6ce76ed095abd315e26e6e1193af3af" ;;
  *)     WANT_SHA="${OSD_PKG_SHA:-}" ;;
esac
if [ ! -f "$TARBALL" ]; then
  URL="https://github.com/jqlang/jq/releases/download/jq-$VER/jq-$VER.tar.gz"
  echo "fetching $URL"
  curl -fsSL -o "$TARBALL" "$URL"
fi
GOT_SHA="$(sha256sum "$TARBALL" | cut -d' ' -f1)"
if [ -n "$WANT_SHA" ]; then
  [ "$GOT_SHA" = "$WANT_SHA" ] || { echo "FATAL: jq-$VER sha mismatch: $GOT_SHA"; exit 1; }
else
  echo "WARNING: no sha pin for jq-$VER -- TOFU via TLS. sha256=$GOT_SHA"
fi
SRC="$P/jq-upstream"
if [ "$(cat "$SRC/.osd-ver" 2>/dev/null)" != "$VER" ]; then
  rm -rf "$SRC"; mkdir -p "$SRC"
  tar xzf "$TARBALL" -C "$SRC" --strip-components=1
  echo "$VER" > "$SRC/.osd-ver"
fi

BUILD="$P/jq-build"
rm -rf "$BUILD"; mkdir "$BUILD"; cd "$BUILD"
"$SRC/configure" --host=wasm32-wasip1 --build=x86_64-pc-linux-gnu \
  CC="$SDK/bin/clang" \
  CFLAGS="--target=wasm32-wasip1 --sysroot=$SDK/share/wasi-sysroot -I$STUBS -D_GNU_SOURCE -D_WASI_EMULATED_SIGNAL -O2 -mllvm -wasm-enable-sjlj" \
  LDFLAGS="-L$COMPAT -lsetjmp -lwasi-emulated-signal -Wl,-z,stack-size=1048576" \
  LIBS="-lwasicompat" \
  AR="$SDK/bin/llvm-ar" RANLIB="$SDK/bin/llvm-ranlib" \
  --without-oniguruma --disable-maintainer-mode --disable-docs
make -j"$(nproc)"
cp jq "$P/jq.wasm"
echo "built: $P/jq.wasm"

STAGE="$HERE/stage"
rm -rf "$STAGE"; mkdir -p "$STAGE/bin"
cp "$P/jq.wasm" "$STAGE/bin/jq"
python3 "$ROOT/tools/pack_pkg.py" --name jq --ver "$VER-r${OSD_PKG_REV:-0}" \
  --desc "command-line JSON processor (no-regex build)" --dir "$STAGE"
