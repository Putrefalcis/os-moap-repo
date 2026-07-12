#!/usr/bin/env bash
# Stage + card-pack the nano package: the editor plus the terminfo entry ncurses
# reads at runtime from the guest FS (no terminfo = "Error opening terminal").
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
P="$HERE/.."
ROOT="$P/../.."
STAGE="$HERE/stage"
[ -f "$P/nano.wasm" ] || { echo "run build.sh first"; exit 1; }
rm -rf "$STAGE"; mkdir -p "$STAGE/bin" "$STAGE/usr/share/terminfo/x"
cp "$P/nano.wasm" "$STAGE/bin/nano"
cp "$P/terminfo-xterm" "$STAGE/usr/share/terminfo/x/xterm"
python3 "$ROOT/tools/pack_pkg.py" --name nano \
  --ver "${OSD_PKG_VER:-8.6}-r${OSD_PKG_REV:-0}" \
  --desc "small, friendly text editor (GNU nano)" --dir "$STAGE"
