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

GAMEDIR=/$directory/ports/alex4
CONFDIR="$GAMEDIR/conf/"
BINARY=alex4.${DEVICE_ARCH}

mkdir -p "$GAMEDIR/conf"

cd $GAMEDIR

> "$GAMEDIR/launch.log" && exec > >(tee "$GAMEDIR/launch.log") 2>&1

export XDG_DATA_HOME="$CONFDIR"
export game_libs="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Original campaign (no args, real intro/outro) or the bundled custom map marathon - see README.md
PICKER=./gamepad-picker.${DEVICE_ARCH}
export GAMEPAD_PICKER_OUTPUT="$GAMEDIR/.picker_result"

"$PICKER" \
  "Alex the Allegator 4|" \
  "Custom Maps|custom_maps/all_packs.a4" \
  > /dev/null
EXTRA_ARG=$(cat "$GAMEPAD_PICKER_OUTPUT")

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
    $ESUDO umount "${weston_dir}"
fi
$ESUDO mount "$controlfolder/libs/${weston_runtime}.squashfs" "${weston_dir}"

$GPTOKEYB "$BINARY" -c "./alex4.gptk" &
pm_platform_helper "$GAMEDIR/$BINARY"

# westonwrap.sh overrides XDG_RUNTIME_DIR; the real one is captured here so PipeWire/PulseAudio can still find its socket
REAL_XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}

$ESUDO env WRAPPED_LIBRARY_PATH=$game_libs \
$weston_dir/westonwrap.sh drm gl kiosk system \
XDG_DATA_HOME=$CONFDIR XDG_RUNTIME_DIR=$REAL_XDG_RUNTIME_DIR $GAMEDIR/$BINARY $EXTRA_ARG

$ESUDO $weston_dir/westonwrap.sh cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
fi
pm_finish
