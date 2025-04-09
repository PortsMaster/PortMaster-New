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
GAMEDIR="/$directory/ports/tabletanks"
TOOLDIR="$GAMEDIR/tools"

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export PATH="$TOOLDIR:$PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

cd $GAMEDIR

# Check if there are .ogg files in port folder
if [ -n "$(ls ./gamedata/*.ogg 2>/dev/null)" ]; then
    # Move all .ogg files from ./gamedata to ./assets
    mkdir -p ./assets
    mv ./gamedata/*.ogg ./assets/

    # Zip the contents of ./game.apk including the .ogg files
    zip -r -0 ./game.apk ./assets/
    rm -Rf "$GAMEDIR/assets/"
fi

# Check if the TableTanks.exe and options.ini file exists
    if [ -f "$GAMEDIR/gamedata/TableTanks.exe" ]; then
		# Delete the redundant files
		rm "$GAMEDIR/gamedata/TableTanks.exe"  
		rm "$GAMEDIR/gamedata/options.ini"  
    fi

# Check for file existence before trying to manipulate them:
[ -f "./gamedata/data.win" ] && mv gamedata/data.win gamedata/game.droid

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO chmod +x -R $GAMEDIR/*

# Splash
[ "$CFW_NAME" == "muOS" ] && splash "splash.png" 1 # workaround for muOS
$ESUDO splash "splash.png" 10000 &

$GPTOKEYB "gmloadernext" -c "controls.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext"

./gmloadernext

pm_finish