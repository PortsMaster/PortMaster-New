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
GAMEDIR="/$directory/ports/caseandbot_murder"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64


# Prepare game files
if [ -f "./assets/CaseAndBot.exe" ]; then
	# Rename data.win
	mv assets/data.win assets/game.droid
	# Delete all redundant files
	rm -f assets/*.{dll,exe,txt}
	# Zip all game files into the casebotitch.port
	zip -r -0 ./casebotitch.port ./assets/
	rm -Rf ./assets/
	# Set gmloader.json to Itch version. 
	sed -i 's|"apk_path" : "game.port"|"apk_path" : "casebotitch.port"|' "$GMLOADER_JSON"

elif [ -f "./assets/Case&Bot.exe" ]; then
	# Rename data.win
	mv assets/data.win assets/game.droid
	# Delete all redundant files
	rm -f assets/*.{dll,exe,txt}
	# Zip all game files into the casebotsteam.port
	zip -r -0 ./casebotsteam.port ./assets/
	rm -Rf ./assets/
	# Set gmloader.json to Steam version. 
	sed -i 's|"apk_path" : "game.port"|"apk_path" : "casebotsteam.port"|' "$GMLOADER_JSON"
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish