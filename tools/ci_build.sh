#!/usr/bin/env bash
# ci_build.sh <name> <upstream-ver> -- build a tracked port at a specific version,
# smoke the wasm, and leave a staged package at guest/pkgs/<name>/stage for
# pack_repo. Exit 0 = ready to publish, non-zero = build or smoke failed (the
# tracker opens an issue and keeps the old version serving). Kept in the source
# repo (not the workflow YAML) so it's runnable + testable locally:
#   tools/ci_build.sh nano 9.1
set -uo pipefail
NAME="$1"; VER="$2"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# ncurses consumers need the static lib built first (its own version is fixed)
needs_ncurses() { case "$1" in nano|sl|less|zsh) return 0;; *) return 1;; esac; }
if needs_ncurses "$NAME"; then
  bash guest/pkgs/ncurses/build.sh || { echo "ci_build: ncurses dep failed"; exit 1; }
fi

# build (each recipe: fetch+verify source, compile, pack_pkg to rom/ + stage/)
if [ "$NAME" = nano ]; then
  OSD_PKG_VER="$VER" bash guest/pkgs/nano/build.sh || exit 1
  OSD_PKG_VER="$VER" bash guest/pkgs/nano/package.sh || exit 1
else
  OSD_PKG_VER="$VER" bash "guest/pkgs/$NAME/build.sh" || exit 1
fi

# smoke: run the wasm under run-node and assert it works. The WASI shim (web/wasi)
# is PRIVATE -- absent in the public build repo, present in the product tree. When
# absent, CI is build-only (compile+link+pack, sha-verified); smoke it locally.
# JSPI (WebAssembly.Suspending) is gated behind a flag on some node builds.
JF=""; node -e 'process.exit(typeof WebAssembly.Suspending=="function"?0:1)' 2>/dev/null || JF="--experimental-wasm-jspi"
smoke() {  # smoke <wasm> <want-substring> [argv...]
  if [ ! -f web/wasi/run-node.mjs ]; then
    echo "ci_build: shim absent -- build-only (smoke '$2' locally)"; return 0
  fi
  local wasm="$1" want="$2"; shift 2
  local out
  out=$(cd web/wasi && echo q | OSD_WASM="../../guest/pkgs/$wasm" node $JF run-node.mjs "$@" 2>&1)
  echo "$out" | grep -q "$want" || { echo "ci_build: $NAME smoke FAILED (want '$want'): $out" | head -3; return 1; }
}
case "$NAME" in
  nano)   smoke nano.wasm "version $VER" nano --version || exit 1 ;;
  tree)   smoke tree.wasm "$VER" tree --version || exit 1 ;;
  jq)     smoke jq.wasm "$VER" jq --version || exit 1 ;;
  lua)    smoke lua.wasm "Lua 5.4" lua -v || exit 1 ;;
  figlet) smoke figlet.wasm "FIGlet" figlet -I1 2>/dev/null || smoke figlet.wasm "$VER" figlet -v || exit 1 ;;
  less)   smoke less.wasm "less $VER" less --version || exit 1 ;;
  zsh)    smoke zsh.wasm "zsh $VER" zsh --version || exit 1 ;;
  sqlite3) smoke sqlite3.wasm "$VER" sqlite3 --version || exit 1 ;;
  sl)     ;;  # pure animation, no --version; a clean build is the gate
  *)      echo "ci_build: no smoke wired for $NAME (built ok, publishing unsmoked)" ;;
esac
echo "ci_build: $NAME $VER OK (stage at guest/pkgs/$NAME/stage)"
