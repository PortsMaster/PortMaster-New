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
GAMEDIR="/$directory/ports/psebay"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x "$GAMEDIR/gmloadernext.aarch64"

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Prepare game files
if [ -f ./assets/data.win ]; then
	# get data.win checksum for full and demo version
	checksum=$(md5sum "assets/data.win" | awk '{ print $1 }')
		# Full version patch
		if [ "$checksum" == "07808a9404a1adda3981341a723e4c96" ]; then
		$controlfolder/xdelta3 -d -s "$GAMEDIR/assets/data.win" -f "$GAMEDIR/tools/psebay.xdelta" "$GAMEDIR/assets/game.droid" 2>&1
		echo "Data.win file for the full version has been patched"
		# Demo version patch
		elif [ "$checksum" = "90c83ffa429b5e3df009efa72a48ed6f" ]; then
		$controlfolder/xdelta3 -d -s "$GAMEDIR/assets/data.win" -f "$GAMEDIR/tools/psebaydemo.xdelta" "$GAMEDIR/assets/game.droid" 2>&1
		echo "Data.win file for the demo version has been patched"
	else
	    # Rename data.win file
	    mv assets/data.win assets/game.droid
	fi
	
	# Delete all redundant files
	rm -f assets/*.{exe,dll,win}
	# Make saves dir
	mkdir -p ./saves
	# Move folders
	for d in ./assets/*/; do
	    base=$(basename "$d")
	    lower=$(echo "$base" | tr '[:upper:]' '[:lower:]')
	    mv -v "$d" "./saves/$lower"
	done
	# Move options.ini if present
	if [ -f ./assets/options.ini ]; then
	    mv ./assets/options.ini ./saves/options.ini
	fi
	# Zip all game files into the psebay.port
	zip -r -0 ./psebay.port ./assets/
	rm -Rf ./assets/
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish