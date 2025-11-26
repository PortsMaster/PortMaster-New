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
GAMEDIR="/$directory/ports/derelict"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Prepare game files
if [ -f "$GAMEDIR/assets/Derelict.zip" ]; then
	# Unzip the GBJam5 version into the gamedata directory
	unzip -j -o assets/Derelict.zip "Derelict (Original GBJam5 Entry)/*" -x *.exe *.ini *.dll -d assets
	# Apply the patch
	$controlfolder/xdelta3 -d -s "$GAMEDIR/assets/data.win" -f "$GAMEDIR/tools/patch.xdelta" "$GAMEDIR/assets/game.droid" 2>&1
	# Delete all redundant files
	rm -f assets/*.{exe,dll,win,zip}
	# Zip all game files into the derelict.port
	zip -r -0 ./derelict.port ./assets/
	rm -Rf ./assets/
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "derelict.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish