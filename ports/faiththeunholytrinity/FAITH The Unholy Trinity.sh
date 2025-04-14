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

# Variables
GAME_NAME=faiththeunholytrinity
GAMEDIR="/$directory/ports/$GAME_NAME"
PATCH_MIN_TIME=5 #In Minutes
PATCH_MAX_TIME=10 #In Minutes

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export GAME_NAME
export GAMEDIR
export PATCHER_FILE="$GAMEDIR/tools/patchscript"
export PATCHER_GAME="$(basename "${0%.*}")" # This gets the current script filename without the extension
export PATCHER_TIME="$PATCH_MIN_TIME to $PATCH_MAX_TIME minutes"
export AARCH
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$GAMEDIR/tools/libs:$LD_LIBRARY_PATH"

# Check if patchlog.txt to skip patching
if [ ! -f patchlog.txt ]; then
    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb)
    else
        echo "This port requires the latest version of PortMaster." > $CUR_TTY
    fi
else
    echo "Patching process already completed. Skipping."
fi

# Assign gptokeyb and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "$GAME_NAME.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c gmloader.json

# Cleanup by killing processes
pm_finish
