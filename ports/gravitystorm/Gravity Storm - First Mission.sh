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

export controlfolder

source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# Variables
GAMEDIR="/$directory/ports/gravitystorm"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# CD and set up logging
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x "$GAMEDIR/gmloadernext.aarch64"

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/lib:$LD_LIBRARY_PATH"

# Prepare game files
if [ -f ./assets/data.win ]; then
	# get data.win checksum
	checksum=$(md5sum "assets/data.win" | awk '{ print $1 }')
	
	# Check for Steam demo version
	if [ "$checksum" == "015b735453bee276b4c6a3cd03f07b17" ]; then
		sed -i 's|"apk_path" : "gravitystorm.port"|"apk_path" : "gravitystormdemo.port"|' $GMLOADER_JSON
		# Rename data.win file
		mv assets/data.win assets/game.droid
		# Delete all redundant files
		rm -f assets/*.{exe,dll}
		# Zip all game files into the gravitystormdemo.port
		zip -r -0 ./gravitystormdemo.port ./assets/
		rm -Rf ./assets/
	
	# Assume full version
	else 
		# Rename data.win file
		mv assets/data.win assets/game.droid
		# Delete all redundant files
		rm -f assets/*.{exe,dll}
		# Zip all game files into the gravitystorm.port
		zip -r -0 ./gravitystorm.port ./assets/
		rm -Rf ./assets/
	fi
fi

# Assign gptokeyb and load the game
$GPTOKEYB "gmloadernext.aarch64" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Kill processes
pm_finish
