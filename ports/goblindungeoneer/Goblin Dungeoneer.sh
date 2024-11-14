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


GAMEDIR="/$directory/ports/goblindungeoneer"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_windows"

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Permissions
$ESUDO chmod +x "$GAMEDIR/gmloader"

# check if we have new enough version of PortMaster that contains xdelta3
if [ ! -f "$controlfolder/xdelta3" ]; then
  echo "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info." > /dev/tty0
  sleep 5
  exit 1
fi

# Patch game
cd "$GAMEDIR"
# If "gamedata/data.win" exists and matches the checksum of the itch or steam versions
if [ -f "./gamedata/data.win" ]; then
    checksum=$(md5sum "./gamedata/data.win" | awk '{print $1}')
    
    # Checksum for the Itch version
    if [ "$checksum" = "f82b47d89d29af535c0a27c2a2bf52d5" ]; then
        $ESUDO $controlfolder/xdelta3 -d -s gamedata/data.win -f ./patch/itch.xdelta gamedata/game.droid && \
        rm -f "gamedata/data.win"
        rm -f "gamedata/Place data.win here"
    # Checksum for the Steam version
    elif [ "$checksum" = "3cfef6de9806eb3e07eda4626d3fba0a" ]; then
        $ESUDO $controlfolder/xdelta3 -d -s gamedata/data.win -f ./patch/steam.xdelta gamedata/game.droid && \
        rm -f gamedata/data.win
        rm -f "gamedata/Place data.win here"
    else
        echo "Error: MD5 checksum of game.unx does not match any expected version."
        exit 1
    fi
else    
    echo "Error: Missing files in gamedata folder or game has been patched."
fi

$GPTOKEYB "gmloader" &

$ESUDO chmod +x "$GAMEDIR/gmloader"
pm_platform_helper "$GAMEDIR/gmloader"
./gmloader goblindungeoneer.apk

pm_finish
printf "\033c" > /dev/tty0
