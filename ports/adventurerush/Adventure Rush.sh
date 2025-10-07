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
GAMEDIR="/$directory/ports/adventurerush"
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
		if [ "$checksum" == "45a21a274222e38770ae78b2b6585722" ]; then
		sed -i 's|"apk_path" : "adventurerush.port"|"apk_path" : "adventurerushdemo.port"|' $GMLOADER_JSON
		mv assets/data.win assets/game.droid
		rm -f assets/*.{exe,dll}
		# Zip all game files into the adventurerushdemo.port
		zip -r -0 ./adventurerushdemo.port ./assets/
		rm -Rf ./assets/
	else
		# Apply a patch for a full version
		$controlfolder/xdelta3 -d -s "$GAMEDIR/assets/data.win" -f "$GAMEDIR/tools/patch.xdelta" "$GAMEDIR/assets/game.droid" 2>&1
		echo "Patch has been applied"
		rm -f assets/*.{exe,dll,win}
		# Zip all game files into the adventurerush.port
		zip -r -0 ./adventurerush.port ./assets/
		rm -Rf ./assets/
	fi
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "adventurerush.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish