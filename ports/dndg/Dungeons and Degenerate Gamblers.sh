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


GAMEDIR=/$directory/ports/dndg

godot_runtime="godot_4.6.3"
godot_executable="godot463.$DEVICE_ARCH"

pck_filename="DnDG_64.pck"

mkdir -p "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

CONFDIR="$GAMEDIR/conf/"
$ESUDO mkdir -p "${CONFDIR}"

weston_dir=/tmp/weston
$ESUDO mkdir -p "${weston_dir}"
weston_runtime="weston_pkg_0.2"
if [ ! -f "$controlfolder/libs/${weston_runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi
  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${weston_runtime}.squashfs"
fi
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
  $ESUDO umount "${weston_dir}" 2>/dev/null || true
fi
$ESUDO mount "$controlfolder/libs/${weston_runtime}.squashfs" "${weston_dir}"

godot_dir=/tmp/godot
$ESUDO mkdir -p "${godot_dir}"
if [ ! -f "$controlfolder/libs/${godot_runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi
  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${godot_runtime}.squashfs"
fi
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
  $ESUDO umount "${godot_dir}" 2>/dev/null || true
fi
$ESUDO mount "$controlfolder/libs/${godot_runtime}.squashfs" "${godot_dir}"

cd "$GAMEDIR"

chmod +x "$GAMEDIR/tools/SDL_swap_gpbuttons.py"
"$GAMEDIR/tools/SDL_swap_gpbuttons.py" -i "$SDL_GAMECONTROLLERCONFIG_FILE" -o "$GAMEDIR/gamecontrollerdb_swapped.txt" -l "$GAMEDIR/SDL_swap_gpbuttons.txt"
export SDL_GAMECONTROLLERCONFIG_FILE="$GAMEDIR/gamecontrollerdb_swapped.txt"
export SDL_GAMECONTROLLERCONFIG="`echo "$SDL_GAMECONTROLLERCONFIG" | "$GAMEDIR/tools/SDL_swap_gpbuttons.py" -l "$GAMEDIR/SDL_swap_gpbuttons.txt"`"

$GPTOKEYB2 "godot463" -x &

$ESUDO env WRAPPED_PRELOAD_PANFROST="$GAMEDIR/libcrusty.so" CRUSTY_BLOCK_INPUT=1 $weston_dir/westonwrap.sh headless noop kiosk crusty_x11egl \
XDG_DATA_HOME=$CONFDIR $godot_dir/$godot_executable \
--resolution ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT} -f \
--rendering-driver opengl3_es --audio-driver ALSA --main-pack $GAMEDIR/gamedata/$pck_filename \
--steam_compatibility

$ESUDO $weston_dir/westonwrap.sh cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
  $ESUDO umount "${weston_dir}"
  $ESUDO umount "${godot_dir}"
fi

pm_finish
