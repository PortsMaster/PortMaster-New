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
GAMEDIR="/$directory/ports/fares"
GMLOADER_JSON="$GAMEDIR/gmloader.json"
TOOLDIR="$GAMEDIR/tools"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x $GAMEDIR/gmlnext.aarch64

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Prepare game files
if [ -f ./assets/data.win ]; then
	# Apply patch for controls
	$controlfolder/xdelta3 -d -s "$GAMEDIR/assets/data.win" -f "$GAMEDIR/tools/patch.xdelta" "$GAMEDIR/assets/game.droid" 2>&1
	# Delete all redundant files
	rm -f assets/*.{exe,win,dll}
	# Zip all game files into the fares.port
	zip -r -0 ./fares.port ./assets/
	rm -Rf ./assets/
fi

# Assign configs and load the game
$GPTOKEYB2 "gmlnext.aarch64" -c "controls.ini" &
pm_platform_helper "$GAMEDIR/gmlnext.aarch64"
# GPTOKEYB2 has issues with executables with too long names, so truncated to gmlnext.aarch64 it is.
./gmlnext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish
