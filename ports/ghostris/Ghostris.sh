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

export PORT_32BIT="Y"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/ghostris"

export LD_LIBRARY_PATH="/usr/lib32:/$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

cd $GAMEDIR

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Extract and prepare the game files.  
if [ -f "$GAMEDIR/gamedata/Ghostris_2020HalloweenUpdate.zip" ]; then

	# Unzip necessary files into the gamedata directory
	unzip -j -o "$GAMEDIR/gamedata/Ghostris_2020HalloweenUpdate.zip" -x *.exe *.ini -d gamedata

	# Patch the data.win file
	$controlfolder/xdelta3 -d -s "./gamedata/data.win" "./patch/ghostrispatch.xdelta" "./gamedata/game.droid"

	# Move all .ogg files from gamedata folder to ./assets
	mkdir -p ./assets
	mv ./gamedata/*.ogg ./assets/

	# Zip the contents of ./game.apk including the .ogg files
	zip -r -0 ./game.apk ./assets/

	# Delete no longer needed files and folders
	rm -Rf "$GAMEDIR/assets/"
	rm ./gamedata/Ghostris_2020HalloweenUpdate.zip
	rm ./gamedata/data.win
	rm -Rf "$GAMEDIR/patch"
else
	echo "Ghostris_2020HalloweenUpdate.zip is missing, skipping the extraction step"
fi

$ESUDO chmod +x "$GAMEDIR/gmloader"

$GPTOKEYB "gmloader" -c "ghostris.gptk" &
pm_platform_helper "$GAMEDIR/gmloader"
./gmloader game.apk

pm_finish
