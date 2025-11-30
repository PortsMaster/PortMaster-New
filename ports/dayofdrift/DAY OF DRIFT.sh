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
GAMEDIR="/$directory/ports/dayofdrift"

# CD and set logging
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Setup permissions
$ESUDO chmod +xwr "$GAMEDIR/gmloadernext.aarch64"

# Exports
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Patcher setup
check_patch() {
	if [ ! -f patchlog.txt ] &&  [ -f "$GAMEDIR/assets/data.win" ]; then
		if [ -f "$controlfolder/utils/patcher.txt" ]; then
			export PATCHER_FILE="$GAMEDIR/tools/patchscript"
			export PATCHER_GAME="$(basename "${0%.*}")"
			export PATCHER_TIME="about 10 minutes"
			export controlfolder
			export ESUDO
			source "$controlfolder/utils/patcher.txt"
			$ESUDO kill -9 $(pidof gptokeyb)
		else
			echo "This port requires the latest version of PortMaster."
		fi
	fi
}

# Check if we need to start the patcher as it is not needed on high-end devices
if [[ "$DEVICE_RAM" -ge 4 ]] && [ -f "$GAMEDIR/assets/data.win" ]; then 
	if [ -f ./assets/data.win ]; then
	# Patch to fix controls
	$controlfolder/xdelta3 -d -s "$GAMEDIR/assets/data.win" -f "$GAMEDIR/tools/patchhe.xdelta" "$GAMEDIR/assets/game.droid" 2>&1
	# Delete all redundant files
	rm -f assets/*.{exe,dll,win}
	# Zip all game files into the dayofdrift.port
	zip -r -0 ./dayofdrift.port ./assets/
	rm -Rf ./assets/
	fi
else
	check_patch
fi


# Assign gptokeyb and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "dayofdrift.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c gmloader.json

# Cleanup
pm_finish
