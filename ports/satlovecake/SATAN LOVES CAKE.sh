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

GAMEDIR=/$directory/ports/satlovecake

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export LD_LIBRARY_PATH="$GAMEDIR/lib:/usr/lib32:$LD_LIBRARY_PATH"

cd "$GAMEDIR"

# Rename data.win to game.droid if it exists in the main folder
if [ -e "$GAMEDIR/data.win" ]; then
    mv "$GAMEDIR/data.win" "$GAMEDIR/game.droid" || exit 1
    echo "Renamed data.win to game.droid."
elif [ ! -e "$GAMEDIR/data.win" ] || [ ! -e "$GAMEDIR/game.droid" ]; then
    echo "No data.win or game.droid file found in the main folder."
fi

$ESUDO chmod +x "$GAMEDIR/gmloadernext"

# Start game with game.droid file in $GAMEDIR
$GPTOKEYB "gmloadernext" &
pm_platform_helper "$GAMEDIR/gmloadernext"
./gmloadernext

pm_finish
