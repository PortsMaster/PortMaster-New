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

GAMEDIR="/$directory/ports/hauntedlandsburial"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_linux"

cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Check if .exe exists
if [ -f "./gamedata/Haunted Lands Burial Grounds 1.1.0.exe" ]; then
    # Extract its contents in place using 7zzs
    ./libs/7zzs x "./gamedata/Haunted Lands Burial Grounds 1.1.0.exe" -o"./gamedata/" ||
    exit1
fi

# Array of files to remove 
files_to_remove=("./gamedata/Haunted Lands Burial Grounds 1.1.0.exe"
"./gamedata/D3DX9_43.dll"
"./gamedata/Haunted Lands.exe"
"./gamedata/hl_config.ini"
"./gamedata/options.ini"
"./gamedata/gmsched.dll"
"./gamedata/uninstall.exe")

# Loop through each file and remove it 
for file in "${files_to_remove[@]}"; do rm -f "$file" 
done 

# Check if there are .ogg files in ./gamedata
if [ -n "$(ls ./gamedata/*.ogg 2>/dev/null)" ]; then
    # Move all .ogg files from ./gamedata to ./assets
    mkdir -p ./assets
    mv ./gamedata/*.ogg ./assets/ || exit 1

    # Zip the contents of ./hauntedlandsburial.apk including the .ogg files
    zip -r -0 ./hauntedlandsburial.apk ./assets/ || exit 1
    rm -Rf "$GAMEDIR/assets/" || exit 1
fi

# Rename data.win to game.droid if it exists
[ -f "./gamedata/data.win" ] && mv gamedata/data.win gamedata/game.droid

$GPTOKEYB "gmloader" -c "./hauntedlandsburial.gptk" &
echo "Loading, please wait... " > /dev/tty0

$ESUDO chmod +x "$GAMEDIR/gmloader"
pm_platform_helper "$GAMEDIR/gmloader"
./gmloader hauntedlandsburial.apk

pm_finish
