#!/usr/bin/env bash
# hello: the permanent E2E test package -- bin/hello = the walking-skeleton wasm
# (interactive echo loop; `echo exit | hello` prints its banner and exits).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
P="$HERE/.."
ROOT="$P/../.."
STAGE="$HERE/stage"
rm -rf "$STAGE"; mkdir -p "$STAGE/bin"
cp "$ROOT/guest/skeleton/skeleton.wasm" "$STAGE/bin/hello"
python3 "$ROOT/tools/pack_pkg.py" --name hello --ver 1.0-r0 \
  --desc "walking-skeleton echo program (spawn test)" --dir "$STAGE"
