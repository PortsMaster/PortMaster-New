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

GAMEDIR="/$directory/ports/shirobimetal"

export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

cd $GAMEDIR

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Rename data.win
[ -f "./data.win" ] && mv data.win game.droid


# Check if there are .ogg files in port folder
if [ -n "$(ls ./*.ogg 2>/dev/null)" ]; then
    # Move all .ogg files from port folder to ./assets
    mkdir -p ./assets
    mv ./*.ogg ./assets/ || exit 1

    # Zip the contents of ./game.apk including the .ogg files
    zip -r -0 ./game.apk ./assets/ || exit 1
    rm -Rf "$GAMEDIR/assets/" || exit 1
fi

$GPTOKEYB "gmloadernext" -c "shirobi.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext"

$ESUDO chmod +x "$GAMEDIR/gmloadernext"

./gmloadernext

pm_finish
