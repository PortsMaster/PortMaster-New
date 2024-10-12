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

GAMEDIR="/$directory/ports/biomassgrowth"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

# Extract the game files
if [ -f "$GAMEDIR/gamedata/Biomass Growth 20211213.exe" ]; then
    		
	# Use 7zip to extract the Biomass Growth 20211213.exe file to the destination directory
    	"$GAMEDIR/patch/7zzs" -aos x "$GAMEDIR/gamedata/Biomass Growth 20211213.exe" -o"$GAMEDIR/gamedata" 
   
   	# Delete all redundant files
	rm "$GAMEDIR/gamedata/Biomass Growth 20211213.exe"  
	rm "$GAMEDIR/gamedata/D3DX9_43.dll"
	rm "$GAMEDIR/gamedata/options.ini"  
else
	echo "The exe file is missing, skipping the extraction step!"
fi

# Rename data.win
[ -f "./gamedata/data.win" ] && mv gamedata/data.win gamedata/game.droid

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

$GPTOKEYB "gmloader" &
pm_platform_helper $GAMEDIR/gmloader
./gmloader game.apk

pm_finish
