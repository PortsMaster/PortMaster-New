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

GAMEDIR="/$directory/ports/nidhogg"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_linux"

# We log the execution of the script into log.txt
exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

if [ -f "${controlfolder}/libgl_${CFWNAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

# check if we have new enough version of PortMaster that contains xdelta3
if [ ! -f "$controlfolder/xdelta3" ]; then
  echo "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info." > /dev/tty0
  sleep 5
  exit 1
fi

#Patch Game
cd $GAMEDIR

# If "gamedata/data.win" exists and its MD5 checksum matches the specified value, apply the xdelta3 patch
if [ -f "./gamedata/data.win" ]; then
    checksum=$(md5sum "./gamedata/data.win" | awk '{print $1}')
    if [ "$checksum" = "c0131d7435ff2a646eec51f7cdde8029" ]; then
        $ESUDO $controlfolder/xdelta3 -d -s gamedata/data.win -f ./patch/data.xdelta gamedata/game.droid && \
        rm gamedata/data.win
    else
        echo "Error: MD5 checksum of data.win does not match the expected checksum."    
    fi
else
    echo "Error: Missing files in gamedata folder OR game has been patched"
fi


# Check if Nidhogg.exe exists in the /gamedata folder and delete it if it does
if [ -f "./gamedata/Nidhogg.exe" ]; then
    rm ./gamedata/Nidhogg.exe
    echo "Deleted Nidhogg.exe from ./gamedata/"
fi

# Check if there are .ogg files in ./gamedata and move them to the appropriate places
if [ -n "$(ls ./gamedata/*.ogg 2>/dev/null)" ]; then
    # Move all .ogg files from ./gamedata to ./assets
    mv ./gamedata/*.ogg ./assets/
    echo "Moved ogg files from ./gamedata to ./assets/"
    
    # Copy Nidhogg_OST folder to ./assets
    if [ -d "$GAMEDIR/gamedata/Nidhogg_OST" ]; then
    cp -r "$GAMEDIR/gamedata/Nidhogg_OST" ./assets/
    echo "Copied Nidhogg_OST folder to ./assets/"
    fi

    # Zip the contents of ./nidhogg.apk including the new .ogg files
    zip -r -0 ./nidhogg.apk ./nidhogg.apk ./assets/
    echo "Zipped contents to ./nidhogg.apk"
    rm -Rf "$GAMEDIR/assets/"
fi

# Make sure uinput is accessible so we can make use of the gptokeyb controls
$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "gmloader" -c ./nidhogg.gptk &

$ESUDO chmod +x "$GAMEDIR/gmloader"

./gmloader nidhogg.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0

