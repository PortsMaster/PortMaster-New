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
GAMEDIR="/$directory/ports/hatchwell"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x -R $GAMEDIR/*

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"

# Patch game
cd "$GAMEDIR"

# Check for file existence before trying to manipulate them:
[ -f "./gamedata/data.win" ] && mv gamedata/data.win gamedata/game.droid

if [ -n "$(ls ./gamedata/*.dat 2>/dev/null)" ]; then
    # Move all audiogroup.dat from ./gamedata to ./assets
    mkdir -p ./assets
    mv ./gamedata/*.dat ./assets/ || exit 1
    echo "Moved audiogroup.dat files from ./gamedata to ./assets/"	

    # Zip the contents of ./game.apk including the new .ogg and .wav files
    zip -r -0 ./game.apk ./assets/ || exit 1
    echo "Zipped contents to ./game.apk"
    rm -Rf "$GAMEDIR/assets/" || exit 1

fi

# Check if either "Hatchwell.exe"exists
if [ -f "./gamedata/Hatchwell.exe" ]; then    
    # Remove extra files from Steam or Itch.io builds
    rm -Rf "./gamedata/Hatchwell.exe" \
           "./gamedata/"*.dll \
	   "./gamedata/Place game files here" 
    echo "Extra game files removed"
else    
    echo "No extra game files to remove"
fi

# Display loading splash
if [ -f "$GAMEDIR/gamedata/game.droid" ]; then
[ "$CFW_NAME" == "muOS" ] && $ESUDO ./lib/splash "splash.png" 1 # muOS only workaround
    $ESUDO ./lib/splash "splash.png" 2000
fi

# Run the game
$GPTOKEYB "gmloadernext" -c "./hatchwell.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext"
./gmloadernext

# Kill processes
pm_finish
