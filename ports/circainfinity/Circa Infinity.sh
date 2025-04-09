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

get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

GAMEDIR="/$directory/ports/circainfinity"

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x -R $GAMEDIR/*

cd "$GAMEDIR"

# Exports
export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=0
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_windows"

# Extract the full version
if [ -f "$GAMEDIR/gamedata/CircaInfinity.exe" ]; then
    		
	# Use 7zip to extract the CircaInfinity.exee file to the destination directory
    	"$GAMEDIR/tools/7zzs" -aos x "$GAMEDIR/gamedata/CircaInfinity.exe" -o"$GAMEDIR/gamedata" 
   
   	# Delete all redundant files
	rm "$GAMEDIR/gamedata/CircaInfinity.exe"  
	rm "$GAMEDIR/gamedata/D3DX9_43.dll"
	rm "$GAMEDIR/gamedata/steam_api.dll"
	rm "$GAMEDIR/gamedata/options.ini"  
else
	pm_message "The exe file is missing, skipping the extraction step!"
fi

# Extract the demo version
if [ -f "$GAMEDIR/gamedata/CircaInfinityDemo.exe" ]; then
    		
	# Use 7zip to extract the CircaInfinityDemo.exe file to the destination directory
    	"$GAMEDIR/tools/7zzs" -aos x "$GAMEDIR/gamedata/CircaInfinityDemo.exe" -o"$GAMEDIR/gamedata" 
   
   	# Delete all redundant files
	rm "$GAMEDIR/gamedata/CircaInfinityDemo.exe"  
	rm "$GAMEDIR/gamedata/D3DX9_43.dll"
	rm "$GAMEDIR/gamedata/options.ini"  
else
	pm_message "The exe file is missing, skipping the extraction step!"
fi

# Rename the data file
[ -f "./gamedata/data.win" ] && mv gamedata/data.win gamedata/game.droid

# Pack all .ogg files into game.apk ./gamedata
if [ -n "$(ls ./gamedata/*.ogg 2>/dev/null)" ]; then
    # Move all .ogg files from ./gamedata to ./assets
    mkdir -p ./assets
    mv ./gamedata/*.ogg ./assets/ || exit 1

    # Zip the contents of ./game.apk
    zip -r -0 ./game.apk ./assets/ || exit 1
    rm -Rf "$GAMEDIR/assets/" || exit 1
fi

$GPTOKEYB "gmloader" &

pm_platform_helper "$GAMEDIR/gmloader"
./gmloader game.apk

pm_finish
