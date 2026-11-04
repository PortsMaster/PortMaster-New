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

runtime="pmjs_2026.11.03"
runtime_dir="/tmp/${runtime}-isat"
mkdir -p "$runtime_dir"
$ESUDO umount "$runtime_dir" || true
$ESUDO mount "$controlfolder/libs/${runtime}.squashfs" "$runtime_dir"
pm_platform_helper "$runtime_dir/bin/node"

XDG_CACHE_HOME="$GAMEDIR/.cache" \
  "$runtime_dir/bin/pmjs" "$GAMEDIR" \
  --save-root "$GAMEDIR/saves" --asset-cache-root "$GAMEDIR/.cache"
status=$?
$ESUDO umount "$runtime_dir"
pm_finish
exit "$status"
