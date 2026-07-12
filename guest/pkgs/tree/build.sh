#!/usr/bin/env bash
# tree -> wasm32-wasip1. The friendliest port so far: compiles clean, zero patches.
# Alpine-tracked (edge/main); source = gitlab.com/OldManProgrammer/unix-tree.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
P="$HERE/.."
ROOT="$P/../.."
SDK="${SDK:-$ROOT/build/wasi-sdk}"
STUBS="$P/../busybox/wasi-stubs/include"
COMPAT="$P/../busybox/wasi-compat"

VER="${OSD_PKG_VER:-2.3.2}"
TARBALL="$P/tree-$VER.tar.gz"
case "$VER" in
  2.3.2) WANT_SHA="513a53cbc42ca1f4ea06af2bab1f5283524a3848266b1d162416f8033afc4985" ;;
  *)     WANT_SHA="${OSD_PKG_SHA:-}" ;;
esac
if [ ! -f "$TARBALL" ]; then
  URL="https://gitlab.com/OldManProgrammer/unix-tree/-/archive/$VER/unix-tree-$VER.tar.gz"
  echo "fetching $URL"
  curl -fsSL -o "$TARBALL" "$URL"
fi
GOT_SHA="$(sha256sum "$TARBALL" | cut -d' ' -f1)"
if [ -n "$WANT_SHA" ]; then
  [ "$GOT_SHA" = "$WANT_SHA" ] || { echo "FATAL: tree-$VER sha mismatch: $GOT_SHA"; exit 1; }
else
  echo "WARNING: no sha pin for tree-$VER -- TOFU via TLS. sha256=$GOT_SHA"
fi
SRC="$P/tree-upstream"
if [ "$(cat "$SRC/.osd-ver" 2>/dev/null)" != "$VER" ]; then
  rm -rf "$SRC"; mkdir -p "$SRC"
  tar xzf "$TARBALL" -C "$SRC" --strip-components=1
  echo "$VER" > "$SRC/.osd-ver"
fi

"$SDK/bin/clang" --target=wasm32-wasip1 --sysroot="$SDK/share/wasi-sysroot" \
  -I"$STUBS" -D_GNU_SOURCE -O2 -o "$P/tree.wasm" "$SRC"/*.c \
  -L"$COMPAT" -lwasicompat
echo "built: $P/tree.wasm"

STAGE="$HERE/stage"
rm -rf "$STAGE"; mkdir -p "$STAGE/bin"
cp "$P/tree.wasm" "$STAGE/bin/tree"
python3 "$ROOT/tools/pack_pkg.py" --name tree --ver "$VER-r${OSD_PKG_REV:-0}" \
  --desc "list directory contents in a tree" --dir "$STAGE"
