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
GAMEDIR="/$directory/ports/touhoucirno"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x -R $GAMEDIR/*

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Extract and prepare the game files.  
if [ -f gamedata/FrogStreet__v1_1__itchio.zip ]; then

	# Unzip necessary files
	unzip -o ./gamedata/FrogStreet__v1_1__itchio.zip -x *.exe *.ini *.png -d gamedata

	# Move bgm folder with .ogg files to ./assets
	mkdir -p ./assets
	mv ./gamedata/bgm ./assets/

	# Zip the contents of ./game.apk including the .ogg files
	zip -r -0 ./touhoucirno.port ./assets/

	# Move and rename data.win
	mv ./gamedata/data.win ./gamedata/game.droid

	# Delete no longer needed files and folders
	rm -Rf ./assets/
	rm  ./gamedata/FrogStreet__v1_1__itchio.zip
else
	echo "FrogStreet__v1_1__itchio.zip is missing, skipping the extraction step"
fi

# Assign configs and load the game
$GPTOKEYB "gmloader.aarch64" -c "touhoucirno.gptk" &
pm_platform_helper "gmloader.aarch64"
./gmloader.aarch64 -c gmloader.json

# Cleanup
pm_finish
