#!/bin/bash
# PORTMASTER: tsunderswap.zip, TS Underswap.sh

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
GAMEDIR="/$directory/ports/tsunderswap"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x -R $GAMEDIR/*

# Check for file existence before trying to manipulate them:
[ -f "./gamedata/data.win" ] && mv gamedata/data.win gamedata/game.droid
[ -f "./gamedata/game.unx" ] && mv gamedata/game.unx gamedata/game.droid

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" 

# Check for .dat files and move to APK
    if [ -n "$(ls ./gamedata/*.dat 2>/dev/null)" ]; then
    mkdir -p ./assets
    mv ./gamedata/*.dat ./assets/
    echo "Moved .dat files to ./assets/"

    zip -r -0 ./game.apk ./assets/
    echo "Zipped contents to ./game.apk"

    rm -rf ./assets
    echo "Deleted assets directory"
else
    echo "No .dat files found"
fi

# Display loading splash
if [ -f "$GAMEDIR/gamedata/game.droid" ]; then
    $ESUDO ./tools/splash "splash.png" 1 
    $ESUDO ./tools/splash "splash.png" 2000
fi

# Run the game
$GPTOKEYB "gmloadernext.aarch64" &
pm_platform_helper "gmloadernext"
./gmloadernext.aarch64 -c gmloader.json

# Kill processes
pm_finish
