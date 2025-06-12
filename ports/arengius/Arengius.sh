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
GAMEDIR="/$directory/ports/arengius"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64

# Installation process
if [ -f "$GAMEDIR/assets/Arengius_Full_v1_0.zip" ]; then
	# Unzip the Arengius_Full_v1_0.zip to the destination directory
	unzip -j -o assets/Arengius_Full_v1_0.zip -d assets
	# Update to bytecode 16
	$controlfolder/xdelta3 -d -s "$GAMEDIR/assets/data.win" -f "$GAMEDIR/tools/patchfull.xdelta" "$GAMEDIR/assets/game.droid" 2>&1
	# Remove redundant files
	rm -f assets/*.{dll,win,exe,txt,zip}
	# Zip all game files into the arengius.port and remove now needless assets folder
	zip -r -0 ./arengius.port ./assets/
	rm -Rf ./assets/
	
  elif  [ -f "$GAMEDIR/assets/Arengius_Lite_v1_0.zip" ]; then
	# Unzip the Arengius_Lite_v1_0.zip to the destination directory
	unzip -j -o assets/Arengius_Lite_v1_0.zip -d assets
	# Update to bytecode 16
	$controlfolder/xdelta3 -d -s "$GAMEDIR/assets/data.win" -f "$GAMEDIR/tools/patchlite.xdelta" "$GAMEDIR/assets/game.droid" 2>&1
	# Remove redundant files
	rm -f assets/*.{dll,win,exe,txt,zip}
	# Zip all game files into the arengius.port and remove now needless assets folder
	zip -r -0 ./arengius.port ./assets/
	rm -Rf ./assets/
else    
    echo "No correct zip file is present, skipping the installation process."
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "arengius.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish