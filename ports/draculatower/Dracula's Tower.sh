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
GAMEDIR="/$directory/ports/draculatower"
GMLOADER_JSON="$GAMEDIR/gmloader.json"
TOOLDIR="$GAMEDIR/tools"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
$ESUDO chmod +x $GAMEDIR/gmloadernext.${DEVICE_ARCH}

# Prepare game files
if [ -f "$GAMEDIR/assets/DRACULAS_TOWER_V2_itchio.zip" ]; then
	# Unzip necessary files
	unzip -o ./assets/DRACULAS_TOWER_V2_itchio.zip -x *.exe -d assets
	
	# Rename data.win
	mv assets/data.win assets/game.droid
	
	# Delete no longer needed files and folders
	rm -f assets/*.{zip,txt}
	
	# Zip the assets folder into draculatower.port
	zip -r -0 ./draculatower.port ./assets/
	
	# Zip the assets folder into draculatower.port
	rm -Rf ./assets/
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "draculatower.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish