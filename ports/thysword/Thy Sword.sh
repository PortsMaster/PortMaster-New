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

GAMEDIR="/$directory/ports/thysword"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_windows"

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Permissions
$ESUDO chmod +x $GAMEDIR/tools/SDL_swap_gpbuttons.py
$ESUDO chmod +x $GAMEDIR/gmloader

# check if we have new enough version of PortMaster that contains xdelta3
if [ ! -f "$controlfolder/xdelta3" ]; then
  pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
  sleep 5
  exit 1
fi

# Change Drive and Patch Game
cd "$GAMEDIR"

# If "gamedata/data.win" exists and matches the checksum of the itch or steam versions
if [ -f "./gamedata/data.win" ]; then
    checksum=$(md5sum "./gamedata/data.win" | awk '{print $1}')
    
    # Checksum for the Steam version
    if [ "$checksum" = "aefda0536e3f55e0deac7d8e150ceb27" ]; then
        $ESUDO $controlfolder/xdelta3 -d -s gamedata/data.win -f ./tools/thyswordsteam.xdelta gamedata/game.droid && \
        rm gamedata/data.win
	rm -f "gamedata/place data.win here"
	pm_message "Steam version of the game has been patched"
    # Checksum for the Itch version
    elif [ "$checksum" = "05e81de7e15b109379f91886230f8d05" ]; then
        $ESUDO $controlfolder/xdelta3 -d -s gamedata/data.win -f ./tools/thysworditch.xdelta gamedata/game.droid && \
        rm gamedata/data.win
        rm -f "gamedata/place data.win here"
	pm_message "Itch.io version of the game has been patched"
    else
        pm_message "Error: MD5 checksum of data.win does not match any expected version."
        exit 1
    fi
fi

# dos2unix in case we need it
dos2unix "$GAMEDIR/tools/SDL_swap_gpbuttons.py"

# Swap buttons
"$GAMEDIR/tools/SDL_swap_gpbuttons.py" -i "$SDL_GAMECONTROLLERCONFIG_FILE" -o "$GAMEDIR/gamecontrollerdb_swapped.txt" -l "$GAMEDIR/SDL_swap_gpbuttons.txt"
export SDL_GAMECONTROLLERCONFIG_FILE="$GAMEDIR/gamecontrollerdb_swapped.txt"
export SDL_GAMECONTROLLERCONFIG="`echo "$SDL_GAMECONTROLLERCONFIG" | "$GAMEDIR/tools/SDL_swap_gpbuttons.py" -l "$GAMEDIR/SDL_swap_gpbuttons.txt"`"

$GPTOKEYB "gmloader" &

$ESUDO chmod +x "$GAMEDIR/gmloader"
pm_platform_helper "$GAMEDIR/gmloader"
./gmloader game.apk

pm_finish
