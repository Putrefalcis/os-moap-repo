#!/usr/bin/env bash
# less -> wasm32-wasip1. ncurses consumer (needs ../ncurses/build.sh first); ships
# its own terminfo like nano/sl. Built --with-secure: shell escapes / pipes / v-edit
# / LESSOPEN all need fork+exec, which the prim doesn't have -- secure mode compiles
# them out honestly ("Command not available" instead of a hung ENOSYS).
# Port patch: open_tty() prefers fd 0 when stdin IS the terminal -- there's no
# /dev/tty in the guest and less's fd-2 fallback is write-only under the shim.
# (`cmd | less` interactive paging stays unsupported: in a pipeline the keyboard
# has nowhere to go; with stdout non-tty less copies input through like cat.)
# Alpine-tracked (main). Source: greenwoodsoftware.com.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
P="$HERE/.."
ROOT="$P/../.."
SDK="${SDK:-$ROOT/build/wasi-sdk}"
STUBS="$P/../busybox/wasi-stubs/include"
COMPAT="$P/../busybox/wasi-compat"

VER="${OSD_PKG_VER:-704}"
TARBALL="$P/less-$VER.tar.gz"
case "$VER" in
  704) WANT_SHA="20a0b0a2bb2525fa53c7eee9beb854b4c9cf172eabb209af7020743547bfe9fb" ;;
  *)   WANT_SHA="${OSD_PKG_SHA:-}" ;;
esac
if [ ! -f "$TARBALL" ]; then
  URL="https://www.greenwoodsoftware.com/less/less-$VER.tar.gz"
  echo "fetching $URL"
  curl -fsSL -o "$TARBALL" "$URL"
fi
GOT_SHA="$(sha256sum "$TARBALL" | cut -d' ' -f1)"
if [ -n "$WANT_SHA" ]; then
  [ "$GOT_SHA" = "$WANT_SHA" ] || { echo "FATAL: less-$VER sha mismatch: $GOT_SHA"; exit 1; }
else
  echo "WARNING: no sha pin for less-$VER -- TOFU via TLS. sha256=$GOT_SHA"
fi
SRC="$P/less-upstream"
if [ "$(cat "$SRC/.osd-ver" 2>/dev/null)" != "$VER" ]; then
  rm -rf "$SRC"; mkdir -p "$SRC"
  tar xzf "$TARBALL" -C "$SRC" --strip-components=1
  chmod -R u+w "$SRC"    # less ships its sources 0444; the tty patch needs write
  echo "$VER" > "$SRC/.osd-ver"
fi
[ -f "$P/ncurses-build/lib/libncursesw.a" ] || { echo "run ../ncurses/build.sh first"; exit 1; }

# keyboard = stdin when stdin is the tty (no /dev/tty; fd 2 can't be read)
if ! grep -q 'OS-MOAP' "$SRC/ttyin.c"; then
  python3 - "$SRC/ttyin.c" <<'EOF'
import sys
p = sys.argv[1]; s = open(p).read()
anchor = "\tint fd = -1;\n"
patch = anchor + """#ifdef __wasi__
\t/* OS-MOAP: no /dev/tty in the guest, and the fd-2 fallback below is a
\t   write-only stream under the WASI shim. When stdin IS the terminal
\t   (the normal `less file` case), read keys from fd 0. */
\tif (isatty(0))
\t\treturn 0;
#endif
"""
assert s.count(anchor) == 1, "open_tty anchor not found"
open(p, "w").write(s.replace(anchor, patch))
EOF
  echo "patched ttyin.c (fd-0 keyboard)"
fi

BUILD="$P/less-build"
rm -rf "$BUILD"; mkdir "$BUILD"; cd "$BUILD"
"$SRC/configure" --host=wasm32-wasip1 --build=x86_64-pc-linux-gnu \
  CC="$SDK/bin/clang" \
  CFLAGS="--target=wasm32-wasip1 --sysroot=$SDK/share/wasi-sysroot -I$STUBS -I$P/ncurses-build/include -I$P/ncurses-build/include/ncursesw -D_GNU_SOURCE -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_PROCESS_CLOCKS -D_WASI_EMULATED_GETPID -O2 -mllvm -wasm-enable-sjlj -Wno-error=implicit-function-declaration" \
  LDFLAGS="-L$P/ncurses-build/lib -L$COMPAT -lsetjmp -lwasi-emulated-signal -lwasi-emulated-process-clocks -lwasi-emulated-getpid -Wl,-z,stack-size=1048576" \
  LIBS="-lwasicompat" \
  AR="$SDK/bin/llvm-ar" RANLIB="$SDK/bin/llvm-ranlib" \
  ac_cv_have_decl_sigsetjmp=no \
  ac_cv_func_popen=no \
  --with-secure
# seeds: wasi-libc DECLARES sigsetjmp but libsetjmp only implements setjmp/longjmp;
# popen exists as a stub symbol but pclose doesn't -- both die at link if detected.
make -j"$(nproc)" less
cp less "$P/less.wasm"
echo "built: $P/less.wasm"

STAGE="$HERE/stage"
rm -rf "$STAGE"; mkdir -p "$STAGE/bin" "$STAGE/usr/share/terminfo/x"
cp "$P/less.wasm" "$STAGE/bin/less"
cp "$P/terminfo-xterm" "$STAGE/usr/share/terminfo/x/xterm"
python3 "$ROOT/tools/pack_pkg.py" --name less --ver "$VER-r${OSD_PKG_REV:-0}" \
  --desc "pager for viewing text files (secure build)" --dir "$STAGE"
