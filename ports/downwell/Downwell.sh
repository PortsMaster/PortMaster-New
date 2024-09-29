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

get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

$ESUDO chmod 666 /dev/tty0

GAMEDIR="/$directory/ports/downwell"

export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/libs:$LD_LIBRARY_PATH"

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

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
    
    # Checksum for the GOG version
    if [ "$checksum" = "fbecdea0ad4ce643e627fc9aca8e9841" ]; then
        $ESUDO $controlfolder/xdelta3 -d -s gamedata/data.win -f ./patch/downwellgog.xdelta gamedata/game.droid && \
        rm gamedata/data.win
    # Checksum for the Steam version
    elif [ "$checksum" = "3ca6acd5af13997786e27bb5694fb103" ]; then
        $ESUDO $controlfolder/xdelta3 -d -s gamedata/data.win -f ./patch/downwellsteam.xdelta gamedata/game.droid && \
        rm gamedata/data.win
    else
        echo "Error: MD5 checksum of data.win does not match any expected version."
    fi
else    
    echo "Error: Missing files in gamedata folder or game has been patched."
fi

# Pack Audio into apk and move game files to the right place
if [ -n "$(ls ./gamedata/*.dat 2>/dev/null)" ]; then
    # Move all audiogroup.dat from ./gamedata to ./assets
    mkdir -p ./assets
    mv ./gamedata/*.dat ./assets/ || exit 1
    mv ./gamedata/*.ogg ./assets/ || exit 1
    echo "Moved audiogroup.dat files from ./gamedata to ./assets/"	

    # Zip the contents of ./game.apk including the new .ogg and .wav files
    zip -r -0 ./game.apk ./assets/ || exit 1
    echo "Zipped contents to ./game.apk"
    rm -Rf "$GAMEDIR/assets/" || exit 1

    # cleanup if extra files were copied in from steam or gog
    rm -Rf "$GAMEDIR/gamedata/Downwell.exe" \
           "$GAMEDIR/gamedata/"*.dll \
           "$GAMEDIR/gamedata/"*.ico \
           $GAMEDIR/gamedata/gog* \
           $GAMEDIR/gamedata/unins000*

    # Move all files from gamedir/gamedata to gamedir and delete gamedata folder
    mv "$GAMEDIR/gamedata"/* "$GAMEDIR" && rm -rf "$GAMEDIR/gamedata" || exit 1
    echo "Moving and Cleaning of game files done"
fi

$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "gmloadernext" -c ./downwell.gptk &

$ESUDO chmod +x "$GAMEDIR/gmloadernext"

./gmloadernext game.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0