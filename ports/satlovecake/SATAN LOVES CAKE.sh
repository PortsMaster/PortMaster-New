#!/bin/bash

# Set XDG_DATA_HOME if not already set
XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

# Check for PortMaster installation in various directories
if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

# PortMaster info
source $controlfolder/control.txt
export PORT_32BIT="Y"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls
GAMEDIR=/$directory/ports/satlovecake

# Enable logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Set necessary exports
export LD_LIBRARY_PATH="/usr/lib:/usr/lib32:$GAMEDIR/lib:$LD_LIBRARY_PATH"

# Change to the game directory
cd "$GAMEDIR"

# Rename data.win to game.droid if it exists in the main folder
if [ -e "$GAMEDIR/data.win" ]; then
    mv "$GAMEDIR/data.win" "$GAMEDIR/game.droid" || exit 1
    echo "Renamed data.win to game.droid."
else
    echo "No data.win file found in the main folder."
fi

# Ensure necessary permissions
$ESUDO chmod +x "$GAMEDIR/gmloadernext"

# Start game with game.droid file in $GAMEDIR
$GPTOKEYB "gmloadernext" &
pm_platform_helper "$GAMEDIR/gmloadernext"
./gmloadernext

pm_finish
