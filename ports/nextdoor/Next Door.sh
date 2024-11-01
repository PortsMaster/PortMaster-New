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

get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

# Variables
GAMEDIR="/$directory/ports/nextdoor"

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

cd $GAMEDIR

if [ -f "$GAMEDIR/gamedata/NextDoor_v1.00.exe" ]; then
		
	# Use 7zip to extract the NextDoor_v1.00.exe file to the destination directory
    "$GAMEDIR/patch/7zzs" -aos x "$GAMEDIR/gamedata/NextDoor_v1.00.exe" -o"$GAMEDIR/gamedata" & pid=$!

    # Wait for the extraction process to complete
    wait $pid
else
	echo "The exe file is missing, skipping the extraction step!"
fi

# Patch data.win file
if [ -f "./gamedata/data.win" ]; then
    $controlfolder/xdelta3 -d -s "./gamedata/data.win" "./patch/nextdoor.xdelta3" "./gamedata/game.droid"
    [ $? -eq 0 ] && rm "./gamedata/data.win" || echo "Patching of data.win has failed"
    # Delete unneeded files
    rm -f gamedata/*.{ini,exe} 
    rm -rf gamedata/\$*
fi

# Check if there are .ogg files in port folder
if [ -n "$(ls ./gamedata/*.ogg 2>/dev/null)" ]; then
    # Move all .ogg files from ./gamedata to ./assets
    mkdir -p ./assets
    mv ./gamedata/*.ogg ./assets/

    # Zip the contents of ./game.apk including the .ogg files
    zip -r -0 ./game.apk ./assets/
    rm -Rf "$GAMEDIR/assets/"
fi

$ESUDO chmod +x -R $GAMEDIR/*

$GPTOKEYB "gmloadernext" -c "controls.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext"

./gmloadernext

pm_finish
