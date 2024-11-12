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
GAMEDIR="/$directory/ports/utyellow"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x -R $GAMEDIR/*

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export PATCHER_FILE="$GAMEDIR/tools/patchscript"
export PATCHER_GAME="$(basename "${0%.*}")" # This gets the current script filename without the extension
export PATCHER_TIME="2 to 5 minutes"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# dos2unix in case we need it
dos2unix "$GAMEDIR/tools/gmKtool.py"
dos2unix "$GAMEDIR/tools/Klib/GMblob.py"
dos2unix "$GAMEDIR/tools/patchscript"

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

# Display loading splash
if [ -f "$GAMEDIR/patchlog.txt" ]; then
    $ESUDO ./libs/splash "splash.png" 1 
    $ESUDO ./libs/splash "splash.png" 3000
fi

# Assign gptokeyb and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "yellow.gptk" &
pm_platform_helper "gmloadernext"
./gmloadernext.aarch64 -c gmloader.json

# Cleanup
pm_finish
