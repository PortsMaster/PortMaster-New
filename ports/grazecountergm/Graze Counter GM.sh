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

# Variables
GAMEDIR="/$directory/ports/grazecountergm"
LOGFILE="$GAMEDIR/log.txt"

# CD and set permissions
cd $GAMEDIR
exec > >(tee -a "$LOGFILE") 2>&1

$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64
$ESUDO chmod +x $GAMEDIR/patch/patchscript

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export PATCHER_FILE="$GAMEDIR/patch/patchscript"
export PATCHER_GAME="Graze Counter GM"
export PATCHER_TIME="5 minutes"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Check if patchlog.txt to skip patching
if [ ! -f patchlog.txt ]; then
    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb)
    else
        pm_message "This port requires the latest version of PortMaster."
    fi
fi

# Assign gptokeyb and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "game.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64" >/dev/null 2>&1
./gmloadernext.aarch64 -c "gmloader.json"

# Cleanup
pm_finish
