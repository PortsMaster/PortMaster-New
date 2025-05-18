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

export controlfolder

source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# Setup permissions
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

# Variables
GAMEDIR="/$directory/ports/darkdeity"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export PATCHER_FILE="$GAMEDIR/tools/patchscript"
export PATCHER_GAME="$(basename "${0%.*}")" # This gets the current script filename without the extension
export PATCHER_TIME="10 to 15 minutes"

# Check if patchlog.txt to skip patching
if [ ! -f patchlog.txt ] || [ -f "GAMEDIR/assets/data.win" ]; then
    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb)
    else
        pm_message "This port requires the latest version of PortMaster."
    fi
fi

# Display loading splash
if [ -f "$GAMEDIR/patchlog.txt" ]; then
    $ESUDO "$GAMEDIR/tools/splash" "$GAMEDIR/splash.png" 1 
    $ESUDO "$GAMEDIR/tools/splash" "$GAMEDIR/splash.png" 4000 &
fi

# Run the game
$GPTOKEYB "gmloadernext.aarch64" -c "./darkdeity.gptk" & 
pm_platform_helper "gmloadernext.aarch64" >/dev/null
./gmloadernext.aarch64 -c gmloader.json

# Kill processes
pm_finish
