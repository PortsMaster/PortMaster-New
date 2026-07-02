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
GAMEDIR="/$directory/ports/singoubreaka"

# CD and set logging
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Setup permissions
$ESUDO chmod +x "$GAMEDIR/gmloadernext.aarch64"

# Exports
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Prepare game files
if [ -f ./assets/data.win ]; then
	# get data.win checksum
	checksum=$(md5sum "assets/data.win" | awk '{ print $1 }')
	# Check for demo version
		# Apply a patch for a demo  version
		if [ "$checksum" == "74b432dc27512ec43bf170c972b5e342" ]; then
		$controlfolder/xdelta3 -d -s "$GAMEDIR/assets/data.win" -f "$GAMEDIR/tools/patchdemo.xdelta" "$GAMEDIR/assets/game.droid" 2>&1
		rm -f assets/*.{exe,dll}
		# Zip all game files into the singoubreaka.port
		zip -r -0 ./singoubreaka.port ./assets/
		rm -Rf ./assets/
	else
		# Apply a patch for a full version
		$controlfolder/xdelta3 -d -s "$GAMEDIR/assets/data.win" -f "$GAMEDIR/tools/patch.xdelta" "$GAMEDIR/assets/game.droid" 2>&1
		echo "Patch has been applied"
		rm -f assets/*.{exe,dll,win}
		# Zip all game files into the singoubreaka.port
		zip -r -0 ./singoubreaka.port ./assets/
		rm -Rf ./assets/
	fi
fi

# Assign gptokeyb and load the game
$GPTOKEYB "gmloadernext.aarch64" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c gmloader.json

# Cleanup
pm_finish
