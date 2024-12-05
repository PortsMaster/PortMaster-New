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

GAMEDIR="/$directory/ports/galaxychampionstv"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_linux"

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

# Swap buttons
$ESUDO chmod +x $GAMEDIR/tools/SDL_swap_gpbuttons.py
"$GAMEDIR/tools/SDL_swap_gpbuttons.py" -i "$SDL_GAMECONTROLLERCONFIG_FILE" -o "$GAMEDIR/gamecontrollerdb_swapped.txt" -l "$GAMEDIR/SDL_swap_gpbuttons.txt"
export SDL_GAMECONTROLLERCONFIG_FILE="$GAMEDIR/gamecontrollerdb_swapped.txt"
export SDL_GAMECONTROLLERCONFIG="`echo "$SDL_GAMECONTROLLERCONFIG" | "$GAMEDIR/tools/SDL_swap_gpbuttons.py" -l "$GAMEDIR/SDL_swap_gpbuttons.txt"`"

# Pack oggs into apk
if [ -n "$(ls ./gamedata/*.ogg 2>/dev/null)" ]; then
    mkdir -p ./assets
    mv ./gamedata/*.ogg ./assets/ 2>/dev/null
    pm_message "Moved .ogg files from ./gamedata to ./assets/"
    zip -r -0 ./game.apk ./assets/
    pm_message "Zipped contents to ./game.apk"
    rm -Rf ./assets/
fi

# Prepare files
[ -f "./gamedata/data.win" ] && mv gamedata/data.win gamedata/game.droid
[ -f "./gamedata/*.exe" ] && rm -f ./gamedata/*.exe
[ -f "./gamedata/*.dll" ] && rm -f ./gamedata/*.dll

$GPTOKEYB "gmloader" -c ./galaxychampionstv.gptk &

$ESUDO chmod +x "$GAMEDIR/gmloader"
pm_platform_helper "$GAMEDIR/gmloader"
./gmloader game.apk

pm_finish
