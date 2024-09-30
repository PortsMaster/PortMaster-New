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
source $controlfolder/device_info.txt
export PORT_32BIT="Y"

get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

$ESUDO chmod 666 /dev/tty0

GAMEDIR="/$directory/ports/zeldafop"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_IBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_linux"

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

# Check if "data.win" exists and its MD5 checksum matches the specified value then apply patch
if [ -f "gamedata/data.win" ]; then
    checksum=$(md5sum "gamedata/data.win" | awk '{print $1}')
    if [ "$checksum" = "4bc348b341653c7578699dcac57ab5bb" ]; then
        $ESUDO $controlfolder/xdelta3 -d -s "gamedata/data.win" -f "./patch/patch.xdelta3" "gamedata/game.droid" && \
        rm "gamedata/data.win"
    fi
fi

# Rename data.win to game.droid if it exists in ./gamedata
if [ -e "./gamedata/data.win" ]; then
    mv ./gamedata/data.win ./gamedata/game.droid || exit 1
fi

# Make sure uinput is accessible so we can make use of the gptokeyb controls
$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "gmloader" &

$ESUDO chmod +x "$GAMEDIR/gmloader"

./gmloader zeldafop.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
