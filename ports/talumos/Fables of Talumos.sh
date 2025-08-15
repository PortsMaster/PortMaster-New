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
GAMEDIR="/$directory/ports/talumos"
GMLOADER_JSON="$GAMEDIR/gmloader.json"
TOOLDIR="$GAMEDIR/tools"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Prepare game files
if [ -f "assets/data.win" ]; then
    # get data.win checksum
    checksum=$(md5sum "assets/data.win" | awk '{ print $1 }')
    
    # Check for Itch.io version
    if [ "$checksum" == "52c0ec0bc6ee065d7c43d0f367aea728" ]; then
        # Apply Itch.io patch
        $controlfolder/xdelta3 -d -s "assets/data.win" "tools/patchitch.xdelta" "assets/game.droid" && rm "assets/data.win"
        # Remove redundant files
        rm -f assets/*.{dll,exe}
        # Zip all game files into the talumos.port
        zip -r -0 ./talumos.port ./assets/
        rm -Rf ./assets/
        echo "Data.win from Itch.io has been patched"
    
    # Check for Steam version
    elif [ "$checksum" == "b04c898585fced8025c0c463a26c9cfb" ]; then
        # Apply Steam patch
        $controlfolder/xdelta3 -d -s "assets/data.win" "tools/patchsteam.xdelta" "assets/game.droid" && rm "assets/data.win"
        # Remove redundant files
        rm -f assets/*.{dll,exe}
        # Zip all game files into the talumos.port
        zip -r -0 ./talumos.port ./assets/
        rm -Rf ./assets/
        echo "Data.win from Steam has been patched"
    
    else
        echo "checksum does not match; wrong build/version of game"
    fi
    
else    
    echo "Missing file in assets folder or game has been patched."
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish