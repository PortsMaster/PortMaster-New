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
GAMEDIR="/$directory/ports/papilio"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="/usr/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64

# Prepare game files
if [ -f ./assets/data.win ]; then
	# Get data.win checksum
	checksum=$(md5sum "assets/data.win" | awk '{ print $1 }')
   
   # Patch for Demo version 
    if [ "$checksum" == "c0cefc0bd7f6e449b8a4b01ebbb2532a" ]; then
        # Apply Demo version patch
        $controlfolder/xdelta3 -d -s "assets/data.win" "tools/patchdemo.xdelta" "assets/game.droid" && rm "assets/data.win"
        # Remove redundant files
        rm -f assets/*.{dll,exe}
        # Zip all game files into the papilio.port
        zip -r -0 ./papilio.port ./assets/
        rm -Rf ./assets/
        pm_message "Demo version has been patched"
    
    # Patch for Full version
    elif [ "$checksum" == "08f86b1a3d2e806a3f1d0e2d8ac66692" ]; then
        # Apply Full version patch
        $controlfolder/xdelta3 -d -s "assets/data.win" "tools/patchfull.xdelta" "assets/game.droid" && rm "assets/data.win"
        # Remove redundant files
        rm -f assets/*.{dll,exe}
        # Zip all game files into the papilio.port
        zip -r -0 ./papilio.port ./assets/
        rm -Rf ./assets/
        pm_message "Full version has been patched"
    fi
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "papilio.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
 ./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish