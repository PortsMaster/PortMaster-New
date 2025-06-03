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
ARCH=aarch64 # armhf or aarch64
GAME_NAME=phasingpuller
GAMEDIR="/$directory/ports/$GAME_NAME"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [ -f ./assets/data.win ]; then # Checking if the data.win exists in assets
    mv assets/data.win assets/game.droid # renaming it to game.droid
    rm -f assets/*.{dll,exe,txt} # removing unnecassery shit
    zip -r -0 ./game.apk ./assets/ # zipping
    rm -Rf ./assets/ # removing the folder
fi

# Exports
export GAME_NAME
export GAMEDIR
export AARCH
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$GAMEDIR/tools/libs:$LD_LIBRARY_PATH"

# dos2unix in case we need it
dos2unix "$GAMEDIR/tools/gmKtool.py"
dos2unix "$GAMEDIR/tools/Klib/GMblob.py"
dos2unix "$GAMEDIR/tools/patchscript"

# Assign gptokeyb and load the game
$GPTOKEYB "gmloadernext.$ARCH" -c "phasingpuller.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.$ARCH"
./gmloadernext.$ARCH -c gmloader.json

# Cleanup by killing processes
pm_finish
