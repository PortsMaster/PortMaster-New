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

export PORT_32BIT="Y"

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR=/$directory/ports/godstone

# Enable logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
cd "$GAMEDIR"

# Set file permissions
$ESUDO chmod +x "$GAMEDIR/gmloadernext.armhf"

# Exports
export PATCHER_FILE="$GAMEDIR/tools/patchscript"
export PATCHER_GAME="Godstone" 
export PATCHER_TIME="2-5 minutes"
export PATH="$PATH:$GAMEDIR/tools"

# Check if patchlog.txt to skip patching
if [ ! -f patchlog.txt ]; then
    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb)
    else
        echo "This port requires the latest version of PortMaster."
    fi
else
    echo "Patching process already completed. Skipping."
fi


export LD_LIBRARY_PATH="$GAMEDIR/libs.armhf:$LD_LIBRARY_PATH"

$GPTOKEYB "gmloadernext.armhf" -c "./godstone.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.armhf"
./gmloadernext.armhf -c gmloader.json

pm_finish
