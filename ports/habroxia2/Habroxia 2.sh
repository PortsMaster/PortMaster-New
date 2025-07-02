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
GAMEDIR="/$directory/ports/habroxia2"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64

# Prepare game files
if [ -f "assets/data.win" ]; then
    # get data.win checksum
    checksum=$(md5sum "assets/data.win" | awk '{ print $1 }')
    
    # Check for Itch.io version
    if [ "$checksum" == "a9aea0bd3f88fb2e8be8f845ce9e192b" ]; then
        # Apply Itch.io patch
        $controlfolder/xdelta3 -d -s "assets/data.win" "tools/patchitch.xdelta" "assets/game.droid" && rm "assets/data.win"
        # Remove redundant files
        rm -f assets/*.{dll,exe,txt}
        # Zip all game files into the habroxia2.port
        zip -r -0 ./habroxia2.port ./assets/
        rm -Rf ./assets/
        echo "Data.win from itch.io has been patched"
    
    # Check for Steam version
    elif [ "$checksum" == "f413de6a972353a955c06b0c111cc27f" ]; then
        # Apply Steam patch
        $controlfolder/xdelta3 -d -s "assets/data.win" "tools/patchsteam.xdelta" "assets/game.droid" && rm "assets/data.win"
        # Remove redundant files
        rm -f assets/*.{dll,exe,txt}
        # Zip all game files into the habroxia2.port
        zip -r -0 ./habroxia2.port ./assets/
        rm -Rf ./assets/
        echo "Data.win from Steam has been patched"
    
    else
        echo "checksum does not match; wrong build/version of game"
    fi
    
else    
    echo "Missing file in assets folder or game has been patched."
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "habroxia2.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish