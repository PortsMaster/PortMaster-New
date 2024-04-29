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

GAMEDIR="/$directory/ports/youdiedbanry"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"

# We log the execution of the script into log.txt
exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

if [ -f "${controlfolder}/libgl_${CFWNAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

# check if we have new engough version of PortMaster that contains xdelta3
if [ ! -f "$controlfolder/xdelta3" ]; then
  echo "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info." > /dev/tty0
  sleep 5
  exit 1
fi

# Patch game
cd "$GAMEDIR"

# If "gamedata/game.unx" exists and matches the checksum of the itch or steam versions
if [ -f "./gamedata/game.unx" ]; then
    checksum=$(md5sum "./gamedata/game.unx" | awk '{print $1}')
    
    # Checksum for the itch.io version
    if [ "$checksum" = "8e431e1cd5919f64d1c301029cadcfcf" ]; then
        $ESUDO $controlfolder/xdelta3 -d -s gamedata/game.unx -f ./patch/itch.xdelta gamedata/game.droid && \
        rm gamedata/game.unx
    # Checksum for the Steam version
    elif [ "$checksum" = "e5173a24f1f4b6b41a1b727a965d00b9" ]; then
        $ESUDO $controlfolder/xdelta3 -d -s gamedata/game.unx -f ./patch/steam.xdelta gamedata/game.droid && \
        rm gamedata/game.unx
    else
        echo "Error: MD5 checksum of game.unx does not match any expected version."
    fi
else    
    echo "Error: Missing files in gamedata folder or game has been patched."
fi


# Make sure uinput is accessible so we can make use of the gptokeyb controls
$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "gmloader" -c ./youdiedbanry.gptk &

$ESUDO chmod +x "$GAMEDIR/gmloader"

./gmloader youdiedbanry.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
