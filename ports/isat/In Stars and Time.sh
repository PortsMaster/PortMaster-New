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

source "$controlfolder/control.txt"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/isat"
cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

runtime="pmjs_v1"
if [ ! -f "$controlfolder/libs/${runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi
  $ESUDO "$controlfolder/harbourmaster" --quiet --no-check runtime_check "${runtime}.squashfs" || exit 1
fi
runtime_dir="/tmp/${runtime}-isat"
mkdir -p "$runtime_dir"
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
  $ESUDO umount "$runtime_dir" || true
fi
$ESUDO mount "$controlfolder/libs/${runtime}.squashfs" "$runtime_dir"
pm_platform_helper "$runtime_dir/bin/node"

XDG_CACHE_HOME="$GAMEDIR/.cache" \
  "$runtime_dir/bin/pmjs" "$GAMEDIR" \
  --save-root "$GAMEDIR/saves" --asset-cache-root "$GAMEDIR/.cache"
status=$?
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
  $ESUDO umount "$runtime_dir"
fi
pm_finish
exit "$status"
