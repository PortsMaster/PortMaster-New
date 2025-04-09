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

GAMEDIR=/$directory/ports/spacegladiators

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"

cd $GAMEDIR

# check if we have new enough version of PortMaster that contains xdelta3
if [ ! -f "$controlfolder/xdelta3" ]; then
  echo "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info." > /dev/tty0
  sleep 5
  exit 1
fi

# Patch game
cd "$GAMEDIR"

# Check if data.zip exists in the patch directory
if [ -f "./patch/data.zip" ]; then
    echo "data.zip found. Unzipping..."
    
    # Unzip the data.zip file into the patch directory
    unzip "./patch/data.zip" -d "./patch/"
    
    # Check if the unzip was successful
    if [ $? -eq 0 ]; then
        echo "Unzip successful. Deleting data.zip..."
        rm "./patch/data.zip"
        echo "data.zip deleted."
    else
        echo "Failed to unzip data.zip."
    fi
else
    echo "data.zip not found in ./patch."
fi

# If "gamedata/data.win" exists and matches the checksum steam version
if [ -f "./gamedata/data.win" ]; then
    checksum=$(md5sum "./gamedata/data.win" | awk '{print $1}')
    # Checksum for the data.win
    if [ "$checksum" = "1bdab689e0a681f64dd6aa4c9402c075" ]; then
        echo "data.win is being patched..." && \
        $ESUDO $controlfolder/xdelta3 -d -s gamedata/data.win -f ./patch/data.xdelta gamedata/game.droid && \
        rm gamedata/data.win
    else
        echo "Error: MD5 checksum of data.win does not match any expected version."
    fi
else    
    echo "Error: Missing files in gamedata folder or game has been patched."
fi

# If "gamedata/game.droid" and "./patch/data.xdelta" exists and matches the checksum steam version
if [ -f "./gamedata/game.droid" ] && [ -f "./patch/data.xdelta" ]; then
    checksum=$(md5sum "./gamedata/game.droid" | awk '{print $1}')
    # Checksum for the game.droid
    if [ "$checksum" = "6d79cd968d9cf229a22d69973ae125e8" ]; then
        echo "data.xdelta deleted" && \
        rm -Rf ./patch
    else
        echo "Error: MD5 checksum of game.droid does not match any expected version. Patching may have failed"
    fi
else    
    echo "data.xdelta not present, if game does not run, kindly re-download the package from PortMaster"
fi

# Check if SpaceGladiators.exe exists in the /gamedata folder and delete it if it does
if [ -f "./gamedata/SpaceGladiators.exe" ]; then
    rm "./gamedata/SpaceGladiators.exe"
    echo "Deleted SpaceGladiators.exe from ./gamedata/"
fi

$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "gmloader" &

$ESUDO chmod +x "$GAMEDIR/gmloader"

./gmloader spacegladiators.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
