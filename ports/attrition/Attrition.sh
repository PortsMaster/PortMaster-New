#!/bin/bash

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
GAMEDIR="/$directory/ports/attrition"
GMLOADER_JSON="$GAMEDIR/gmloader.json"
TOOLDIR="/$GAMEDIR/tools"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x $GAMEDIR/gmloadernext.${DEVICE_ARCH}

# Exports
export LD_LIBRARY_PATH="/usr/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Prepare game files
if [ -f ./assets/data.win ]; then
	# Apply the patch
		checksum=$(md5sum "assets/data.win" | awk '{ print $1 }')
		# Check for full version
		if [ "$checksum" == "7a5db3bd40563e2c12c90a56ac58fd69" ]; then
			$controlfolder/xdelta3 -d -s "$GAMEDIR/assets/data.win" -f "$TOOLDIR/patch.xdelta" "$GAMEDIR/assets/game.droid" 2>&1
			echo "Patch for the full version has been applied"
		# Check for demo version
		elif [ "$checksum" == "2fbb90a662e64053e889abcd06ea0de7" ]; then
			$controlfolder/xdelta3 -d -s "$GAMEDIR/assets//data.win" -f "$TOOLDIR/patchdemo.xdelta" "$GAMEDIR/assets//game.droid" 2>&1
			echo "Patch for the demo version has been applied"
		fi	
	# Delete all redundant files
	rm -f assets/*.{win,exe}
	# Zip all game files into the attrition.port
	zip -r -0 ./attrition.port ./assets/
	rm -Rf ./assets/
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish