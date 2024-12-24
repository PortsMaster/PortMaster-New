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
GAMEDIR="/$directory/ports/wuppo"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x -R $GAMEDIR/*

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export PATCHER_FILE="$GAMEDIR/patch/patchscript"
export PATCHER_GAME="Wuppo" 
export PATCHER_TIME="2 to 4 minutes"

# dos2unix in case of manual installations
dos2unix "$GAMEDIR/patch/patchscript"

# Check if patchlog.txt exists to skip patching
if [ ! -f patchlog.txt ]; then
    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        source "$controlfolder/utils/patcher.txt"
    else
        pm_message "This port requires the latest version of PortMaster."
    fi
fi

# Display loading splash
if [ -f "$GAMEDIR/patchlog.txt" ]; then
    $ESUDO ./tools/splash "cover.png" 1 
    $ESUDO ./tools/splash "cover.png" 5000
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" &
pm_platform_helper "gmloadernext.aarch64"
./gmloadernext.aarch64 -c gmloader.json

# Cleanup
pm_finish
