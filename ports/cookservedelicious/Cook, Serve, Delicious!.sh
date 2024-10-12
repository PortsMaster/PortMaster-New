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
GAMEDIR="/$directory/ports/cookservedelicious"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$GAMEDIR/libs:$LD_LIBRARY_PATH"

# Patch game
cd "$GAMEDIR"

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

# If "gamedata/data.win" exists and matches the checksum of the itch or steam versions
if [ -f "./gamedata/data.win" ]; then
    #Rename the data.win file
    mv "gamedata/data.win" "gamedata/game.droid"
    
    #Remove extra files from steam
    rm -Rf "$GAMEDIR/gamedata/CSDSteamBuild.exe" \
           "$GAMEDIR/gamedata/"*.dll \
else    
    echo "Error: Missing files in gamedata folder or game has been patched."
fi

# Display loading splash
if [ -f "$GAMEDIR/gamedata/game.droid" ]; then
    $ESUDO ./libs/splash "splash.png" 1 
    $ESUDO ./libs/splash "splash.png" 2000
fi

# Run the game
$GPTOKEYB "gmloadernext" -c "./cookservedelicious.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext"
./gmloadernext game.apk

# Kill processes
pm_finish
