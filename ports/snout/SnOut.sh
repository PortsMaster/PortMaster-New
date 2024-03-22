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

GAMEDIR="/$directory/ports/snout"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$GAMEDIR/utils/libs"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"

# We log the execution of the script into log.txt
exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR
# Check if there are .ogg files in ./gamedata and no .ogg in /assets move them to the appropriate places
if [[ -n "$(ls ./gamedata/*.ogg 2>/dev/null)" ]] && [[ ! -f "./assets/*.ogg" ]]; then
    # Copy all .ogg files from ./gamedata to ./assets if there are no .ogg files in ./assets
    cp ./gamedata/*.ogg ./assets/
    echo "Copied ogg files from ./gamedata to ./assets/"
    
    # Copy *.ini files to ./assets
    cp ./gamedata/*.ini ./assets/
    echo "Copied ini files from ./gamedata to ./assets/"
    
    # Copy *.roo files to ./assets
    cp ./gamedata/*.roo ./assets/
    echo "Copied roo files from ./gamedata to ./assets/"
    
    # Zip the contents of ./carriesorderup.apk including the new .ogg files
    zip -r ./test.apk ./test.apk ./assets/
    echo "Zipped contents to ./test.apk" 
else
    echo "Ogg files already exist in ./assets. Skipping copy and zipping."
fi

# Check for file existence before trying to manipulate them:
[ -f "./gamedata/data.win" ] && mv gamedata/data.win gamedata/game.droid
[ -f "./gamedata/game.win" ] && mv gamedata/game.win gamedata/game.droid
[ -f "./gamedata/game.unx" ] && mv gamedata/game.unx gamedata/game.droid

# Make sure uinput is accessible so we can make use of the gptokeyb controls
$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "gmloader" -c ./snout.gptk &

$ESUDO chmod +x "$GAMEDIR/gmloader"

./gmloader snout.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
