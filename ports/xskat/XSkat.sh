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

GAMEDIR=/$directory/ports/xskat
game_executable="xskat.aarch64"

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

CONFDIR="$GAMEDIR/conf"
$ESUDO mkdir -p "$CONFDIR"

weston_dir=/tmp/weston
$ESUDO mkdir -p "${weston_dir}"
weston_runtime="weston_pkg_0.2"
if [ ! -f "$controlfolder/libs/${weston_runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_show_error "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info." --title "PortMaster update needed"
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
  sed -i "s/^deadzone_scale = .*/deadzone_scale = 18/" "$GAMEDIR/xskat.ini"
fi

$GPTOKEYB2 "$game_executable" -c "$GAMEDIR/xskat.ini" &
pm_platform_helper "$GAMEDIR/$game_executable"

$ESUDO env strace="$weston_prefix" CRUSTY_BLOCK_INPUT=1 \
$weston_dir/westonwrap.sh drm gl kiosk system \
XSKAT_FONTDIR="$GAMEDIR/fonts" "$GAMEDIR/$game_executable" -fit -keyboard 2 -opt "$CONFDIR/xskat.opt" -list "$CONFDIR/xskat.lst"

$ESUDO $weston_dir/westonwrap.sh cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
fi
pm_finish
