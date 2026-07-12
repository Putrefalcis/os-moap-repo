#!/usr/bin/env bash
# shellver: version-visible fixture for the apk UPGRADE path. v1.0-r0 goes onto
# CARDS (rom/, served by the mock prim); tools/build_test_repo.sh publishes a
# v2.0-r0 to the mock WEB repo -- the selftest masks the repo, installs v1 from
# cards, unmasks, upgrades, and expects the v2 output. A text file in bin/ runs
# via ash (spawn.mjs dispatches non-wasm as ['sh', path, ...]).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$HERE/../../.."
STAGE="$HERE/stage"
rm -rf "$STAGE"; mkdir -p "$STAGE/bin"
printf '#!/bin/sh\necho shellver says-v1\n' > "$STAGE/bin/shellver"
python3 "$ROOT/tools/pack_pkg.py" --name shellver --ver 1.0-r0 \
  --desc "upgrade-path fixture (v1, cards)" --dir "$STAGE"
