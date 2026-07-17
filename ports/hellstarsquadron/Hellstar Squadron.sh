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
GAMEDIR="/$directory/ports/hellstarsquadron"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64

# Rename the Itch.io exe file because I am way lazy to do it nicer
if [ -f ./assets/HellstarSquadron_v1.1.exe ]; then
	mv assets/HellstarSquadron_v1.1.exe assets/HellStarSquadron.exe
fi

# Prepare game files
if [ -f ./assets/HellStarSquadron.exe ]; then
	# Extract the exe
	"$controlfolder/7zzs.$DEVICE_ARCH" -aoa e "$GAMEDIR/assets/HellStarSquadron.exe" -x!*.exe -o"$GAMEDIR/assets"
	# Get data.win checksum
	checksum=$(md5sum "assets/data.win" | awk '{ print $1 }')
   
   # Patch for Itch.io 
    if [ "$checksum" == "20f0cf8f5a9782e2ed4d55f4cbfb40b7" ]; then
        # Apply Itch.io patch
        $controlfolder/xdelta3 -d -s "assets/data.win" "tools/patchitch.xdelta" "assets/game.droid" && rm "assets/data.win"
        # Remove redundant files
        rm -f assets/*.{dll,exe}
        # Zip all game files into the  hellstarsquadron.port
        zip -r -0 ./hellstarsquadron.port ./assets/
        rm -Rf ./assets/
        echo "Data.win from Itch.io has been patched"
    
    # Patch for Steam version
    elif [ "$checksum" == "9b32fd90defd67bd8a5e45f9bf4eb878" ]; then
        # Apply Steam patch
        $controlfolder/xdelta3 -d -s "assets/data.win" "tools/patchsteam.xdelta" "assets/game.droid" && rm "assets/data.win"
        # Remove redundant files
        rm -f assets/*.{dll,exe}
        # Zip all game files into the hellstarsquadron.port
        zip -r -0 ./hellstarsquadron.port ./assets/
        rm -Rf ./assets/
        echo "Data.win from Steam has been patched"
    fi
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish