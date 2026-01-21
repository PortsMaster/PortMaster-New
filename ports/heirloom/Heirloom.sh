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
GAMEDIR="/$directory/ports/heirloom"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Prepare game files
if [ -f ./assets/data.win ]; then
	# get data.win checksum
	checksum=$(md5sum "assets/data.win" | awk '{ print $1 }')
	# Check for Itch.io demo
		if [ "$checksum" == "458fa891ea9e558ae8240d11a4256450" ]; then
		# Set the demo port file
		sed -i 's|"apk_path" : "heirloom.port"|"apk_path" : "heirloomdemo.port"|' $GMLOADER_JSON
		# Rename data.win file
		mv assets/data.win assets/game.droid
		# Delete all redundant files
		rm -f assets/*.{exe,dll}
		# Zip all game files into the heirloomdemo.port
		zip -r -0 ./heirloomdemo.port ./assets/
		rm -Rf ./assets/
	else
		# Rename data.win file
		mv assets/data.win assets/game.droid
		# Delete all redundant files
		rm -f assets/*.{exe,dll}
		# Zip all game files into the heirloom.port
		zip -r -0 ./heirloom.port ./assets/
		rm -Rf ./assets/
	fi
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "heirloom.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish