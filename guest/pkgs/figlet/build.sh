#!/usr/bin/env bash
# figlet -> wasm32-wasip1. Ships 5 fonts (standard/slant/small/big/banner) at the
# baked /usr/share/figlet. Port notes: needs -include unistd.h (K&R-era code never
# includes it -> implicit getopt), __BEGIN_DECLS/__END_DECLS defined away (glibc
# cdefs-isms in utf8.h), DEFAULTFONTFILE must be "standard" WITHOUT .flf (figlet
# appends the suffix itself -- ".flf.flf" = unable to open), and tmpfile() in
# libwasicompat (zipio wants it; wasi-libc has none). Alpine-tracked (community).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
P="$HERE/.."
ROOT="$P/../.."
SDK="${SDK:-$ROOT/build/wasi-sdk}"
STUBS="$P/../busybox/wasi-stubs/include"
COMPAT="$P/../busybox/wasi-compat"

VER="${OSD_PKG_VER:-2.2.5}"
TARBALL="$P/figlet-$VER.tar.gz"
case "$VER" in
  2.2.5) WANT_SHA="4d366c4a618ecdd6fdb81cde90edc54dbff9764efb635b3be47a929473f13930" ;;
  *)     WANT_SHA="${OSD_PKG_SHA:-}" ;;
esac
if [ ! -f "$TARBALL" ]; then
  URL="http://ftp.figlet.org/pub/figlet/program/unix/figlet-$VER.tar.gz"
  echo "fetching $URL"
  curl -fsSL -o "$TARBALL" "$URL" || \
    curl -fsSL -o "$TARBALL" "https://github.com/cmatsuoka/figlet/archive/refs/tags/$VER.tar.gz"
fi
GOT_SHA="$(sha256sum "$TARBALL" | cut -d' ' -f1)"
if [ -n "$WANT_SHA" ]; then
  [ "$GOT_SHA" = "$WANT_SHA" ] || { echo "FATAL: figlet-$VER sha mismatch: $GOT_SHA"; exit 1; }
else
  echo "WARNING: no sha pin for figlet-$VER -- TOFU via TLS. sha256=$GOT_SHA"
fi
SRC="$P/figlet-upstream"
if [ "$(cat "$SRC/.osd-ver" 2>/dev/null)" != "$VER" ]; then
  rm -rf "$SRC"; mkdir -p "$SRC"
  tar xzf "$TARBALL" -C "$SRC" --strip-components=1
  echo "$VER" > "$SRC/.osd-ver"
fi

"$SDK/bin/clang" --target=wasm32-wasip1 --sysroot="$SDK/share/wasi-sysroot" \
  -I"$STUBS" -D_GNU_SOURCE '-D__BEGIN_DECLS=' '-D__END_DECLS=' \
  -DDEFAULTFONTDIR='"/usr/share/figlet"' -DDEFAULTFONTFILE='"standard"' \
  -include unistd.h -O2 -o "$P/figlet.wasm" \
  "$SRC/figlet.c" "$SRC/zipio.c" "$SRC/crc.c" "$SRC/inflate.c" "$SRC/utf8.c" \
  -L"$COMPAT" -lwasicompat
echo "built: $P/figlet.wasm"

STAGE="$HERE/stage"
rm -rf "$STAGE"; mkdir -p "$STAGE/bin" "$STAGE/usr/share/figlet"
cp "$P/figlet.wasm" "$STAGE/bin/figlet"
for f in standard slant small big banner; do
  cp "$SRC/fonts/$f.flf" "$STAGE/usr/share/figlet/"
done
python3 "$ROOT/tools/pack_pkg.py" --name figlet --ver "$VER-r${OSD_PKG_REV:-0}" \
  --desc "print large ASCII-art text banners" --dir "$STAGE"
