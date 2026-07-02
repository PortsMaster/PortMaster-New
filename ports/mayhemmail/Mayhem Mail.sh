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
GAMEDIR="/$directory/ports/mayhemmail"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Prepare game files
if [ -f ./assets/data.win ]; then
	# get data.win checksum
	checksum=$(md5sum "assets/data.win" | awk '{ print $1 }')
	# Check for the demo version
		if [ "$checksum" == "0dba9acbb52e8ef887e811b6d7e65951" ]; then
		sed -i 's|"apk_path" : "mayhemmaildemo.port"|"apk_path" : "adventurerushdemo.port"|' $GMLOADER_JSON
		mv assets/data.win assets/game.droid
		rm -f assets/*.{exe,dll}
		# Zip all game files into the mayhemmaildemo.port
		zip -r -0 ./mayhemmaildemo.port ./assets/
		rm -Rf ./assets/
	else
		# Assume full version of the game
		mv assets/data.win assets/game.droid
		rm -f assets/*.{exe,dll}
		# Zip all game files into the mayhemmail.port
		zip -r -0 ./mayhemmail.port ./assets/
		rm -Rf ./assets/
	fi
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish