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

export LD_LIBRARY_PATH="/usr/lib:/usr/lib32:/$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

cd $GAMEDIR

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Extract and prepare the game files.  
if [ -f "$GAMEDIR/Ghostris_2020HalloweenUpdate.zip" ]; then
	
	# Unzip necessary files into the gamedata directory
	unzip -j -o Ghostris_2020HalloweenUpdate.zip -x *.exe *.ini
	
	# Patch the data.win file
	$controlfolder/xdelta3 -d -s "./data.win" "./patch/ghostrispatch.xdelta" "./game.droid"
	
	# Move all .ogg files from gamedata folder to ./assets
    mkdir -p ./assets
    mv ./*.ogg ./assets/
    
    # Zip the contents of ./game.apk including the .ogg files
    zip -r -0 ./game.apk ./assets/
    
	# Delete no longer needed files and folders
	rm -Rf "$GAMEDIR/assets/"
	rm Ghostris_2020HalloweenUpdate.zip
	rm -r ./patch
	rm data.win
else
	echo "Ghostris_2020HalloweenUpdate.zip is missing, skipping the extraction step"
fi

$GPTOKEYB "gmloadernext" -c "ghostris.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext"

$ESUDO chmod +x "$GAMEDIR/gmloadernext"

./gmloadernext

pm_finish
