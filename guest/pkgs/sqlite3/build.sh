#!/usr/bin/env bash
# sqlite3 CLI -> wasm32-wasip1. Compiles the amalgamation directly (the autoconf
# tarball's configure is autosetup/jimsh since 3.48 -- not worth cross-coaxing when
# it's two translation units). Upstream has first-class WASI support: -DSQLITE_WASI
# stubs fchmod/fchown/mmap in os_unix and defaults the VFS to "unix-dotfile"
# (lock = O_CREAT|O_EXCL lockfile; fcntl range locks don't exist on wasi), and in
# shell.c it drops pwd.h + defines SQLITE_OMIT_POPEN. SQLITE_NOHAVE_SYSTEM compiles
# out .shell/.system (no subprocesses). No WAL (needs shared mmap), no threads.
# Feature set: FTS5 + R*Tree + math functions (JSON is default-on).
# Alpine-tracked (main, package "sqlite"). Source: sqlite.org autoconf tarball;
# the release-year URL segment is scraped from download.html for unpinned versions.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
P="$HERE/.."
ROOT="$P/../.."
SDK="${SDK:-$ROOT/build/wasi-sdk}"
STUBS="$P/../busybox/wasi-stubs/include"
COMPAT="$P/../busybox/wasi-compat"

VER="${OSD_PKG_VER:-3.53.3}"
# X.Y.Z -> autoconf tarball number XYYZZ00 (3.53.3 -> 3530300)
NUM="$(echo "$VER" | awk -F. '{printf "%d%02d%02d00", $1, $2, $3}')"
TARBALL="$P/sqlite-autoconf-$NUM.tar.gz"
case "$VER" in
  3.53.3) WANT_SHA="c917d7db16648ec95f714974ace5e5dcf46b7dc70e26600a0a102a3141125db0"; YEAR=2026 ;;
  *)      WANT_SHA="${OSD_PKG_SHA:-}"; YEAR="" ;;
esac
if [ ! -f "$TARBALL" ]; then
  if [ -z "$YEAR" ]; then
    PATH_SEG="$(curl -fsSL https://sqlite.org/download.html | grep -oE "[0-9]{4}/sqlite-autoconf-$NUM\.tar\.gz" | head -1)"
    [ -n "$PATH_SEG" ] || { echo "FATAL: sqlite-autoconf-$NUM not on sqlite.org/download.html"; exit 1; }
  else
    PATH_SEG="$YEAR/sqlite-autoconf-$NUM.tar.gz"
  fi
  URL="https://sqlite.org/$PATH_SEG"
  echo "fetching $URL"
  curl -fsSL -o "$TARBALL" "$URL"
fi
GOT_SHA="$(sha256sum "$TARBALL" | cut -d' ' -f1)"
if [ -n "$WANT_SHA" ]; then
  [ "$GOT_SHA" = "$WANT_SHA" ] || { echo "FATAL: sqlite-$VER sha mismatch: $GOT_SHA"; exit 1; }
else
  echo "WARNING: no sha pin for sqlite-$VER -- TOFU via TLS. sha256=$GOT_SHA"
fi
SRC="$P/sqlite3-upstream"
if [ "$(cat "$SRC/.osd-ver" 2>/dev/null)" != "$VER" ]; then
  rm -rf "$SRC"; mkdir -p "$SRC"
  tar xzf "$TARBALL" -C "$SRC" --strip-components=1
  echo "$VER" > "$SRC/.osd-ver"
fi

"$SDK/bin/clang" --target=wasm32-wasip1 --sysroot="$SDK/share/wasi-sysroot" \
  -I"$STUBS" -I"$SRC" \
  -D_GNU_SOURCE -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_PROCESS_CLOCKS -D_WASI_EMULATED_GETPID \
  -DSQLITE_WASI -DSQLITE_THREADSAFE=0 -DSQLITE_OMIT_LOAD_EXTENSION \
  -DSQLITE_OMIT_WAL -DSQLITE_MAX_MMAP_SIZE=0 -DSQLITE_NOHAVE_SYSTEM \
  -DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_MATH_FUNCTIONS \
  -DSQLITE_DEFAULT_MEMSTATUS=0 -DHAVE_USLEEP=1 \
  -O2 -o "$P/sqlite3.wasm" "$SRC/shell.c" "$SRC/sqlite3.c" \
  -L"$COMPAT" -lwasicompat -lwasi-emulated-signal -lwasi-emulated-process-clocks \
  -lwasi-emulated-getpid -Wl,-z,stack-size=1048576
echo "built: $P/sqlite3.wasm"

STAGE="$HERE/stage"
rm -rf "$STAGE"; mkdir -p "$STAGE/bin"
cp "$P/sqlite3.wasm" "$STAGE/bin/sqlite3"
python3 "$ROOT/tools/pack_pkg.py" --name sqlite3 --ver "$VER-r${OSD_PKG_REV:-0}" \
  --desc "SQLite database CLI (fts5, rtree, math)" --dir "$STAGE"
