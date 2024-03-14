#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/device_info.txt
get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

$ESUDO chmod 666 /dev/tty0

GAMEDIR="/$directory/ports/youhave10s2023"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$GAMEDIR/utils/libs"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"

# We log the execution of the script into log.txt
exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

if [ -f "${controlfolder}/libgl${CFWNAME}.txt" ]; then 
  source "${controlfolder}/libgl${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

# Check for You Have 10 Seconds 2023.exe and delete if it exists
if [ -f "$GAMEDIR/gamedata/You Have 10 Seconds 2023.exe" ]; then
    rm "$GAMEDIR/gamedata/You Have 10 Seconds 2023.exe"
    echo "Deleted You Have 10 Seconds 2023.exe from gamedata folder."
fi

# Check if there are .ogg files in ./gamedata
if [ -n "$(ls ./gamedata/*.ogg 2>/dev/null)" ]; then
    # Move all .ogg files from ./gamedata to ./assets
    mv ./gamedata/*.ogg ./assets/
    echo "Moved .ogg files from ./gamedata to ./assets/"

    # Zip the contents of ./sm.apk including the new .ogg files
    zip -r ./youhave10s2023.apk ./youhave10s2023.apk ./assets/
    echo "Zipped contents to ./youhave10s2023.apk"
fi

# Check for file existence before trying to manipulate them:
[ -f "./gamedata/data.win" ] && mv gamedata/data.win gamedata/game.droid
[ -f "./gamedata/game.win" ] && mv gamedata/game.win gamedata/game.droid
[ -f "./gamedata/game.unx" ] && mv gamedata/game.unx gamedata/game.droid

# Make sure uinput is accessible so we can make use of the gptokeyb controls
$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "gmloader" -c ./youhave10s2023.gptk &

$ESUDO chmod +x "$GAMEDIR/gmloader"

./gmloader youhave10s2023.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
