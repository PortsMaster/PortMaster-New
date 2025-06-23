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

# This port was tested only with the steam linux version of the game
# Use the steam console to download via download_depot 242680 242683 1972149697962479575

# Variables
GAMEDIR="/$directory/ports/nuclearthrone"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64

# Prepare game files
if [ -f ./assets/game.unx ]; then
	# Apply a patch
	$controlfolder/xdelta3 -d -s "$GAMEDIR/assets/game.unx" "$GAMEDIR/tools/nuclearthrone.xdelta" "$GAMEDIR/assets/game.droid"
	# Delete all redundant files
	rm -f assets/*.{dll,exe,txt,unx}
	# Zip all game files into the game.port
	zip -r -0 ./game.port ./assets/
	rm -Rf ./assets/
	mkdir -p saves
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" -c ./nuclearthrone.gptk &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish