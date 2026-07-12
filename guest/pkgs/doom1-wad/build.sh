#!/usr/bin/env bash
# doom1.wad -- DOOM shareware 1.9 IWAD as a data-only package. The shareware
# episode is freely redistributable (id's shareware license), which is what
# lets this live in the public repo. Commercial IWADs (doom.wad, doomu.wad,
# doom2.wad) are NOT packaged: drop them anywhere on the prim and run
# `doom -iwad <path>`.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
P="$HERE/.."
ROOT="$P/../.."

VER="${OSD_PKG_VER:-1.9}"
WAD="$P/doom1.wad"
WANT_SHA="1d7d43be501e67d927e415e0b8f3e29c3bf33075e859721816f652a526cac771"
if [ ! -f "$WAD" ]; then
  URL="https://distro.ibiblio.org/slitaz/sources/packages/d/doom1.wad"
  echo "fetching $URL"
  curl -fsSL -o "$WAD" "$URL"
fi
GOT_SHA="$(sha256sum "$WAD" | cut -d' ' -f1)"
[ "$GOT_SHA" = "$WANT_SHA" ] || { echo "FATAL: doom1.wad sha mismatch: $GOT_SHA"; exit 1; }

STAGE="$HERE/stage"
rm -rf "$STAGE"; mkdir -p "$STAGE/usr/share/games/doom"
cp "$WAD" "$STAGE/usr/share/games/doom/doom1.wad"
python3 "$ROOT/tools/pack_pkg.py" --name doom1-wad --ver "$VER-r${OSD_PKG_REV:-0}" \
  --desc "DOOM shareware episode 1 IWAD (Knee-Deep in the Dead)" --dir "$STAGE"
