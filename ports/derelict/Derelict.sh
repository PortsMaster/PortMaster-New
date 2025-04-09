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
# device_info.txt will be included by default

export PORT_32BIT="Y"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/derelict"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

#Extract game files game files 
if [ -f "$GAMEDIR/gamedata/Derelict.zip" ]; then
	
	# Unzip the GBJam5 version into the gamedata directory. Before someone asks why I dont exclude the txt file as well, the unzip would extract it regardless for whatever reason. 
	unzip -j -o gamedata/Derelict.zip "Derelict (Original GBJam5 Entry)/*" -x *.exe *.ini *.dll -d gamedata
	
	# Rename data.win
	mv gamedata/data.win gamedata/game.droid
	
	# Delete redundant files
	rm gamedata/Derelict.zip
	rm gamedata/Changelog.txt
else
	echo "Derelict.zip is missing, skipping the extraction step"
fi

# Pack the .ogg files into game.apk ./gamedata
if [ -n "$(ls ./gamedata/*.ogg 2>/dev/null)" ]; then
    # Move all .ogg files from ./gamedata to ./assets
    mkdir -p ./assets
    mv ./gamedata/*.ogg ./assets/ || exit 1

    # Zip the contents of ./game.apk including the .ogg files
    zip -r -0 ./game.apk ./assets/ || exit 1
    rm -Rf "$GAMEDIR/assets/" || exit 1
fi

$ESUDO chmod +x "$GAMEDIR/gmloader"

$GPTOKEYB "gmloader" -c "derelict.gptk" &
pm_platform_helper "$GAMEDIR/gmloader"
./gmloader game.apk

pm_finish