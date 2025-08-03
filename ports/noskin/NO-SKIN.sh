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
GAMEDIR="/$directory/ports/noskin"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64

# Prepare game files
if [ -f "assets/data.win" ]; then
    # get data.win checksum for the demo from Itch.io
    checksum=$(md5sum "assets/data.win" | awk '{ print $1 }')
		# Checksum for the Itch versio
		if [ "$checksum" == "3771a8e2186bbd6abe03d2b4c9274c7e" ]; then
		sed -i 's|"apk_path" : "noskin.port"|"apk_path" : "noskin-demo.port"|' "$GMLOADER_JSON"
		# Rename data.win
		mv assets/data.win assets/game.droid
		# Delete all redundant files
		rm -f assets/*.{dll,exe,txt}
		# Zip all game files into the noskin-demo.port
		zip -r -0 ./noskin-demo.port ./assets/
		rm -Rf ./assets/
	else
		# Assume full version of the game
		sed -i 's|"apk_path" : "noskin-demo.port"|"apk_path" : "noskin.port"|' "$GMLOADER_JSON"
		# Rename data.win
		mv assets/data.win assets/game.droid
		# Delete all redundant files
		rm -f assets/*.{dll,exe,txt}
		# Zip all game files into the noskin.port
		zip -r -0 ./noskin.port ./assets/
		rm -Rf ./assets/
	fi
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish