#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR=/$directory/ports/tsc
game_executable="tsc.aarch64"
game_libs=$GAMEDIR/libs.${DEVICE_ARCH}/:$LD_LIBRARY_PATH

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

CONFDIR="$GAMEDIR/conf"
$ESUDO mkdir -p "$CONFDIR/tsc"

ARCHIVE_FILES=("data-main.tar.gz" "data-music1.tar.gz" "data-music2.tar.gz")
if [[ -f "${ARCHIVE_FILES[0]}" || -f "${ARCHIVE_FILES[1]}" || -f "${ARCHIVE_FILES[2]}" ]]; then
    pm_message "Extracting game data, this can take a few minutes..." --title "Please wait"
    [[ -d 'data/' ]] && $ESUDO rm -fR 'data/'
    for ARCHIVE_FILE in "${ARCHIVE_FILES[@]}"; do
        if ! gunzip -c "$ARCHIVE_FILE" | tar --no-same-owner -xf -; then
            pm_show_error "Could not extract $ARCHIVE_FILE. Check that there is enough free space, then launch again." --title "Extraction failed"
            exit 1
        fi
    done
    $ESUDO rm -f "${ARCHIVE_FILES[@]}"
elif [ ! -f 'data/music/game/menu.ogg' ] || [ ! -f 'data/levels/menu_brown_1.tsclvl' ]; then
    pm_show_error "No game data found and the archive files are missing. Reinstall the port." --title "Game data missing"
    exit 1
fi

# First run: fullscreen at the panel's resolution, Shoot on Enter so A also confirms menus
if [ ! -f "$CONFDIR/tsc/config.xml" ]; then
  cat > "$CONFDIR/tsc/config.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<config>
  <property name="game_version" value="2.2.0"/>
  <property name="video_fullscreen" value="1"/>
  <property name="video_screen_w" value="${DISPLAY_WIDTH:-640}"/>
  <property name="video_screen_h" value="${DISPLAY_HEIGHT:-480}"/>
  <property name="video_geometry_quality" value="0.5"/>
  <property name="video_texture_quality" value="0.75"/>
  <property name="audio_music_volume" value="80"/>
  <property name="audio_sound_volume" value="100"/>
  <property name="keyboard_key_shoot" value="58"/>
  <property name="keyboard_key_item" value="3"/>
  <property name="joy_enabled" value="0"/>
</config>
EOF
fi

weston_dir=/tmp/weston
$ESUDO mkdir -p "${weston_dir}"
weston_runtime="weston_pkg_0.2"
if [ ! -f "$controlfolder/libs/${weston_runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_show_error "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info." --title "PortMaster too old"
    exit 1
  fi
  pm_message "Downloading the Westonpack runtime, this can take a few minutes..." --title "Please wait"
  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${weston_runtime}.squashfs"
fi
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
fi
$ESUDO mount "$controlfolder/libs/${weston_runtime}.squashfs" "${weston_dir}"

# Mali drivers exporting their own wl_* symbols break Weston unless Wayland is preloaded first
weston_prefix=""
gles_lib=$($weston_dir/tools/findlib libGLESv2.so.2)
if [ -n "$gles_lib" ] && grep -q wl_global_create "$gles_lib"; then
  weston_prefix="env LD_PRELOAD=$weston_dir/lib_aarch64/libwayland-client.so.0:$weston_dir/lib_aarch64/libwayland-server.so.0:$weston_dir/lib_aarch64/graphics/crusty_gbm/libcrusty.so"
fi

if [ "${DISPLAY_WIDTH:-640}" -gt 1280 ]; then
  sed -i "s/^deadzone_scale = .*/deadzone_scale = 18/" "$GAMEDIR/tsc.ini"
fi

$GPTOKEYB2 "$game_executable" -c "$GAMEDIR/tsc.ini" &
pm_platform_helper "$GAMEDIR/$game_executable"

$ESUDO env strace="$weston_prefix" CRUSTY_BLOCK_INPUT=1 WRAPPED_LIBRARY_PATH=$game_libs \
$weston_dir/westonwrap.sh headless noop kiosk crusty_glx_gl4es \
TSC_DATA_DIR="$GAMEDIR/data" XDG_DATA_HOME="$CONFDIR" XDG_CONFIG_HOME="$CONFDIR" XDG_CACHE_HOME="$CONFDIR/cache" \
$GAMEDIR/$game_executable

$ESUDO $weston_dir/westonwrap.sh cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
fi
pm_finish
