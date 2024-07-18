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

GAMEDIR="/$directory/ports/mobility"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$GAMEDIR/utils/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"

# We log the execution of the script into log.txt
exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Check if mobility.tar.gz exists and patch if so
if [ -f "$GAMEDIR/mobility.tar.gz" ]; then
   
    # Change directory to the specified directory
    cd "$GAMEDIR" || exit

    # Use 7zip to extract the .gz file to the destination directory
    "$GAMEDIR/patch/7zzs" x "$GAMEDIR/mobility.tar.gz" -o"$GAMEDIR"

    # Use 7zip to extract the .tar file to the destination directory
    "$GAMEDIR/patch/7zzs" x "$GAMEDIR/mobility.tar" -o"$GAMEDIR" & pid=$!

    # Wait for the extraction process to complete
    wait $pid

    # Move contents of /opt/mobility/assets to $GAMEDIR/gamedata
    mv "$GAMEDIR/opt/mobility/assets"/* "$GAMEDIR/gamedata/"

    # Check if game.unx is in /gamedata and is 21,906,682 bytes big before removing files and folders
    if [ -f "$GAMEDIR/gamedata/game.unx" ] && [ $(stat -c %s "$GAMEDIR/gamedata/game.unx") -eq 21906682 ]; then
        # Delete .tar.gz, .tar, and extracted folders
        rm "$GAMEDIR/mobility.tar.gz" "$GAMEDIR/mobility.tar"
        rm -rf "$GAMEDIR/DEBIAN" "$GAMEDIR/opt"
    fi
fi


cd $GAMEDIR

# Check for file existence before trying to manipulate them:
[ -f "./gamedata/data.win" ] && mv gamedata/data.win gamedata/game.droid
[ -f "./gamedata/game.win" ] && mv gamedata/game.win gamedata/game.droid
[ -f "./gamedata/game.unx" ] && mv gamedata/game.unx gamedata/game.droid

# Make sure uinput is accessible so we can make use of the gptokeyb controls
$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "gmloader" -c ./mobility.gptk &

$ESUDO chmod +x "$GAMEDIR/gmloader"

./gmloader mobility.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0

