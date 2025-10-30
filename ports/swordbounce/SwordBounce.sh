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
GAMEDIR="/$directory/ports/swordbounce"
GMLOADER_JSON="$GAMEDIR/gmloader.json"
TOOLDIR="$GAMEDIR/tools"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Check if the patching needs to be applied
if [ ! -f "$GAMEDIR/patchlog.txt" ] && [ -f "$GAMEDIR/assets/data.win" ]; then
	if [ -f "$controlfolder/utils/patcher.txt" ]; then
		set -o pipefail
		
		# Setup and execute the Portmaster Patcher utility with our patch file
		export ESUDO
		export controlfolder
		export PATCHER_FILE="$GAMEDIR/tools/patchscript"
		export PATCHER_GAME="$(basename "${0%.*}")"
		export PATCHER_TIME="1-2 minutes"
		source "$controlfolder/utils/patcher.txt"
	else
		pm_message "This port requires the latest version of PortMaster."
		pm_finish
		exit 1
	fi
fi

swapabxy() {
  if [ "$CFW_NAME" == "knulli" ] && [ -f "$SDL_GAMECONTROLLERCONFIG_FILE" ]; then
    chmod +x "$TOOLDIR/swapabxy.py" < "$SDL_GAMECONTROLLERCONFIG_FILE" > "$GAMEDIR/gamecontrollerdb_swapped.txt"
    export SDL_GAMECONTROLLERCONFIG_FILE="$GAMEDIR/gamecontrollerdb_swapped.txt"
    export SDL_GAMECONTROLLERCONFIG="$(echo "$SDL_GAMECONTROLLERCONFIG" | "$TOOLDIR/swapabxy.py")"
  else
    echo "Warning: SDL_GAMECONTROLLERCONFIG_FILE is not set or does not exist."
  fi   
}

swapabxy  

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish