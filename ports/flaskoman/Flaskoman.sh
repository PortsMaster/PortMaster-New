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

GAMEDIR=/$directory/ports/flaskoman

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_linux"

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

# Check if there are any .ogg or .mp3 files in the ./gamedata directory
if [ -n "$(ls ./gamedata/*.ogg 2>/dev/null)" ]; then
    # Create the ./assets directory if it doesn't exist
    mkdir -p ./assets
    # Move all .ogg files from ./gamedata to ./assets
    mv ./gamedata/*.ogg ./assets/ 2>/dev/null
    echo "Moved .ogg files from ./gamedata to ./assets/"
    # Zip the contents of ./game.apk including the new audio files
    zip -r -0 ./game.apk ./assets/
    echo "Zipped contents to ./game.apk"
    # Remove the assets directory
    rm -Rf ./assets/
fi

# Check for file existence before trying to manipulate them:
[ -f "./gamedata/data.win" ] && mv gamedata/data.win gamedata/game.droid
[ -f "./gamedata/game.win" ] && mv gamedata/game.win gamedata/game.droid
[ -f "./gamedata/game.unx" ] && mv gamedata/game.unx gamedata/game.droid

# Delete files not required
rm -f ./gamedata/*.exe ./gamedata/*.ini ./gamedata/*.txt

# Make sure uinput is accessible so we can make use of the gptokeyb controls
$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "gmloader" -c ./flaskoman.gptk &

$ESUDO chmod +x "$GAMEDIR/gmloader"

./gmloader game.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
