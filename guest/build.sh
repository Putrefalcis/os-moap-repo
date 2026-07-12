#!/usr/bin/env bash
# OS-MOAP guest build — BusyBox → wasm32-wasip1. Reproduces guest/busybox-v0.wasm.
# Prereqs: wasi-sdk-33 at $SDK; BusyBox 1.36.1 source at guest/busybox/upstream.
# Status (2026-07-11): builds a ~770KB busybox.wasm — real ash + ~22 applets, all in-process
# (NO fork). VERIFIED under node + web/wasi/ shim AND in the SL viewer's CEF (web/term.html
# PASS 9/9, interactive ash + JSPI stdin): redirection >/<, pipelines any length, arithmetic,
# loops, glob, vars, if/test, AND command substitution $(...)/backticks (patch 5 — fresh
# stack arena + saved globals). See patches/README.md + ../../DESIGN.md.
# Needs libwasicompat.a (built here) + config-wasi-v0. Run: cd web/wasi && node run-node.mjs …
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
SDK="${SDK:-$HERE/../build/wasi-sdk}"
BB="$HERE/busybox/upstream"
STUBS="$HERE/busybox/wasi-stubs/include"
COMPAT="$HERE/busybox/wasi-compat"

CFLAGS="--target=wasm32-wasip1 --sysroot=$SDK/share/wasi-sysroot -I$STUBS \
-D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_PROCESS_CLOCKS -D_WASI_EMULATED_GETPID \
-D_WASI_EMULATED_MMAN -mllvm -wasm-enable-sjlj -Wno-implicit-function-declaration \
-include $STUBS/_sockcompat.h -include $STUBS/_bbcompat.h"
LDFLAGS="-lwasi-emulated-mman -lwasi-emulated-signal -lwasi-emulated-process-clocks \
-lwasi-emulated-getpid -mexec-model=command -Wl,-u,__main_argc_argv \
$COMPAT/wasi-compat.o -lsetjmp"

# 1. compat object (weak shims for process/user-id/termios calls wasi-libc lacks)
#    NB: the config's EXTRA_LDFLAGS links -lwasicompat (the ARCHIVE) — rebuild it too,
#    or new stubs silently never reach the link.
"$SDK/bin/clang" --target=wasm32-wasip1 -O2 -I"$STUBS" -c -o "$COMPAT/wasi-compat.o" "$COMPAT/wasi-compat.c"
"$SDK/bin/llvm-ar" rcs "$COMPAT/libwasicompat.a" "$COMPAT/wasi-compat.o"

# 2. config: start from config-wasi-v0 (allnoconfig + ash + core applets + LFS +
#    FEATURE_SH_STANDALONE/PREFER_APPLETS/SH_NOFORK + the flags above baked into
#    CONFIG_EXTRA_CFLAGS/LDFLAGS). If regenerating from scratch, see PORTING.md.
# config carries absolute paths (kconfig has no $(pwd) expansion) -- rebase them
# onto THIS checkout so CI/other machines build identically
sed "s|/home/dkay/src/sl-LSL/OS-MOAP|$(cd "$HERE/.." && pwd)|g" \
  "$HERE/busybox/config-wasi-v0" > "$BB/.config"

# 3. build (host tools with gcc, target with wasi clang)
cd "$BB"
make -j4 HOSTCC=gcc CC="$SDK/bin/clang" SKIP_STRIP=y
cp busybox_unstripped "$HERE/busybox-v0.wasm"
echo "built $HERE/busybox-v0.wasm"
