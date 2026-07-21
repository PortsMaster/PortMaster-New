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

GAMEDIR="/$directory/ports/yarntown_pm"
runtime="solarus-1.6.5"
solarus_dir="$HOME/portmaster-solarus"
solarus_file="$controlfolder/libs/${runtime}.squashfs"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

# Check for runtime
if [ ! -f "$controlfolder/libs/${runtime}.squashfs" ]; then
  # Check for runtime if not downloaded via PM
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi
  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${runtime}.squashfs"
fi

export LD_LIBRARY_PATH="$GAMEDIR/libs:$solarus_dir"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO mkdir -p "$solarus_dir"
$ESUDO umount "$solarus_file" || true
$ESUDO mount "$solarus_file" "$solarus_dir"
PATH="$solarus_dir:$PATH"

$GPTOKEYB "$runtime" -c ./yarntown.gptk & 
pm_platform_helper "$solarus_dir/$runtime"

"$runtime" $GAMEDIR/*.solarus

if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "$solarus_dir"
fi

pm_finish
