#!/usr/bin/env bash
# DOOM -> wasm32-wasip1, in a prim's terminal. Engine: ozkl/doomgeneric (the
# 6-callback linuxdoom-1.10 derivative), pinned by commit. Our backend
# (doomgeneric_osmoap.c, kept here) renders ANSI truecolor half-blocks into
# xterm.js and synthesizes key releases from autorepeat (no key-up on a tty).
# Renders at native 320x200 (no engine-side stretch), downsampled per frame to
# COLUMNS x LINES*2 box-averaged half-block pixels, ~11fps cap.
# FILES_DIR is the only IWAD search dir doomgeneric compiles in (ORIGCODE off);
# -iwad <path> still overrides for other WADs (doomu.wad etc).
# The engine is data-free: WADs ship separately (doom1-wad package).
# Untracked port (no Alpine upstream); bumps are manual.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
P="$HERE/.."
ROOT="$P/../.."
SDK="${SDK:-$ROOT/build/wasi-sdk}"
STUBS="$P/../busybox/wasi-stubs/include"
COMPAT="$P/../busybox/wasi-compat"

VER="${OSD_PKG_VER:-1.0}"
COMMIT="dcb7a8dbc7a16ce3dda29382ac9aae9d77d21284"
TARBALL="$P/doomgeneric-${COMMIT:0:12}.tar.gz"
WANT_SHA="${OSD_PKG_SHA:-}"
SRC="$P/doomgeneric-upstream"
if [ ! -d "$SRC/doomgeneric" ]; then
  if [ ! -f "$TARBALL" ]; then
    URL="https://github.com/ozkl/doomgeneric/archive/$COMMIT.tar.gz"
    echo "fetching $URL"
    curl -fsSL -o "$TARBALL" "$URL"
  fi
  GOT_SHA="$(sha256sum "$TARBALL" | cut -d' ' -f1)"
  if [ -n "$WANT_SHA" ]; then
    [ "$GOT_SHA" = "$WANT_SHA" ] || { echo "FATAL: doomgeneric sha mismatch: $GOT_SHA"; exit 1; }
  else
    echo "NOTE: doomgeneric pinned by commit $COMMIT; tarball sha256=$GOT_SHA"
  fi
  mkdir -p "$SRC"
  tar xzf "$TARBALL" -C "$SRC" --strip-components=1
fi
D="$SRC/doomgeneric"

BUILD="$P/doom-build"
rm -rf "$BUILD"; mkdir "$BUILD"

# doomgeneric's own object list minus the X11 backend (ours replaces it)
SRCS="dummy am_map doomdef doomstat dstrings d_event d_items d_iwad d_loop d_main d_mode d_net f_finale f_wipe g_game hu_lib hu_stuff info i_cdmus i_endoom i_joystick i_scale i_sound i_system i_timer memio m_argv m_bbox m_cheat m_config m_controls m_fixed m_menu m_misc m_random p_ceilng p_doors p_enemy p_floor p_inter p_lights p_map p_maputl p_mobj p_plats p_pspr p_saveg p_setup p_sight p_spec p_switch p_telept p_tick p_user r_bsp r_data r_draw r_main r_plane r_segs r_sky r_things sha1 sounds statdump st_lib st_stuff s_sound tables v_video wi_stuff w_checksum w_file w_main w_wad z_zone w_file_stdc i_input i_video doomgeneric"

CFL="--target=wasm32-wasip1 --sysroot=$SDK/share/wasi-sysroot -I$STUBS -I$D \
 -DNORMALUNIX -DLINUX -D_DEFAULT_SOURCE -D_GNU_SOURCE \
 -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_PROCESS_CLOCKS -D_WASI_EMULATED_GETPID \
 -DDOOMGENERIC_RESX=320 -DDOOMGENERIC_RESY=200 \
 -O2 -Wno-error=implicit-function-declaration"
# (no -DFILES_DIR: doomgeneric's config.h unconditionally redefines it to "."
#  and wins with only a warning -- the wrapper injects -iwad instead)

for s in $SRCS; do
  "$SDK/bin/clang" $CFL -c -o "$BUILD/$s.o" "$D/$s.c" 2>&1 | grep -E 'error' && exit 1 || true
done
"$SDK/bin/clang" $CFL -c -o "$BUILD/doomgeneric_osmoap.o" "$HERE/doomgeneric_osmoap.c"

"$SDK/bin/clang" --target=wasm32-wasip1 --sysroot="$SDK/share/wasi-sysroot" \
  -o "$P/doom.wasm" "$BUILD"/*.o \
  -L"$COMPAT" -lwasicompat -lwasi-emulated-signal -lwasi-emulated-process-clocks \
  -lwasi-emulated-getpid -lm -Wl,-z,stack-size=4194304
echo "built: $P/doom.wasm"

STAGE="$HERE/stage"
rm -rf "$STAGE"; mkdir -p "$STAGE/usr/lib/doom" "$STAGE/bin"
cp "$P/doom.wasm" "$STAGE/usr/lib/doom/doom.wasm"
# wrapper: saves + .cfg land in LSD-synced /home (they survive reboots);
# spawn runs text files via ash, so this is a real entry point
cat > "$STAGE/bin/doom" <<'EOF'
#!/bin/sh
# DOOM. WASD move/strafe, arrows turn, SPACE fire, E use, R run, TAB map.
# Default WAD: $DOOMWAD or /usr/share/games/doom/doom1.wad (apk add doom1-wad);
# pass -iwad <path> for other IWADs (doom.wad, doomu.wad, doom2.wad ...).
cd "$HOME" || cd /
case " $* " in
  *" -iwad "*) exec /usr/lib/doom/doom.wasm "$@" ;;
esac
exec /usr/lib/doom/doom.wasm -iwad "${DOOMWAD:-/usr/share/games/doom/doom1.wad}" "$@"
EOF
chmod +x "$STAGE/bin/doom"
python3 "$ROOT/tools/pack_pkg.py" --name doom --ver "$VER-r${OSD_PKG_REV:-0}" \
  --desc "DOOM (doomgeneric, ANSI half-block renderer)" --dir "$STAGE"
