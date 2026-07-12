#!/usr/bin/env bash
# Checkpoint (b): 20-line curses program proving the ncurses <-> OS-MOAP tty contract.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
PKGS="$HERE/.."
SDK="${SDK:-$PKGS/../../build/wasi-sdk}"
STUBS="$PKGS/../busybox/wasi-stubs/include"
COMPAT="$PKGS/../busybox/wasi-compat"
"$SDK/bin/clang" --target=wasm32-wasip1 --sysroot="$SDK/share/wasi-sysroot" \
  -I"$STUBS" -I"$PKGS/ncurses-build/include" -I"$PKGS/ncurses-build/include/ncursesw" \
  -I"$PKGS/ncurses-upstream/include" \
  -D_WASI_EMULATED_SIGNAL -O2 -Wl,-z,stack-size=1048576 \
  "$HERE/smoke.c" \
  "$PKGS/ncurses-build/lib/libncursesw.a" -L"$COMPAT" -lwasicompat -lwasi-emulated-signal \
  -o "$HERE/smoke.wasm"
echo "built: $HERE/smoke.wasm"
