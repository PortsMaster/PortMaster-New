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
GAMEDIR="/$directory/ports/sidescape"
GMLOADER_JSON="$GAMEDIR/gmloader.json"
TOOLDIR="$GAMEDIR/tools"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64


# Prepare game files
if [ -f ./assets/data.win ]; then
	# get data.win checksum
	checksum=$(md5sum "assets/data.win" | awk '{ print $1 }')
	# Check for Itch.io demo
		if [ "$checksum" == "cc4daabce1ff31eae4ebe46bab64c6d9" ]; then
		sed -i 's|"apk_path" : "sidescape.port"|"apk_path" : "sidescapedemo.port"|' $GMLOADER_JSON
		# Rename data.win file
		mv assets/data.win assets/game.droid
		# Delete all redundant files
		rm -f assets/*.{exe,dll}
		# Zip all game files into the sidescapedemo.port
		zip -r -0 ./sidescapedemo.port ./assets/
		rm -Rf ./assets/
	else
		# Rename data.win file
		mv assets/data.win assets/game.droid
		# Delete all redundant files
		rm -f assets/*.{exe,dll,win}
		# Zip all game files into the sidescape.port
		zip -r -0 ./sidescape.port ./assets/
		rm -Rf ./assets/
	fi
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish