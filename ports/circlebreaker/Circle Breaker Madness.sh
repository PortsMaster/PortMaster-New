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
GAMEDIR="/$directory/ports/circlebreaker"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64
$ESUDO chmod +x $GAMEDIR/tools/7zzs

# Installation process
if [ -f "$GAMEDIR/assets/Circle Breaker Madness 1.0.1.exe" ]; then
	# Use 7zip to extract the Circle Breaker Madness 1.0.1.exe to the destination directory
	"$GAMEDIR/tools/7zzs" -aoa e "$GAMEDIR/assets/Circle Breaker Madness 1.0.1.exe" -x!*.exe -o"$GAMEDIR/assets"
	# Patch the game for better font readability
	$controlfolder/xdelta3 -d -s "$GAMEDIR/assets/data.win" -f "$GAMEDIR/tools/patch.xdelta" "$GAMEDIR/assets/game.droid" 2>&1
	# Remove redundant files
	rm -f assets/*.{dll,win,exe,txt}
	# Zip all game files into the circlebreaker.port and remove now needless assets folder
	zip -r -0 ./circlebreaker.port ./assets/
	rm -Rf ./assets/
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "circlebreaker.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish