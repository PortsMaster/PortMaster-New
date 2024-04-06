#!/bin/bash
# PORTMASTER: redhandsomehood.zip, Red Handsome Hood.sh

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/device_info.txt
export PORT_32BIT="Y"

get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

$ESUDO chmod 666 /dev/tty0

GAMEDIR="/$directory/ports/redhandsomehood"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$GAMEDIR/utils/libs"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_windows"

# We log the execution of the script into log.txt
exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Patch Game
cd "$GAMEDIR"

# Check if RedHandsomeHood.exe exists in the /gamedata folder and delete it if it does
if [ -f "./gamedata/RedHandsomeHood.exe" ]; then
    rm ./gamedata/RedHandsomeHood.exe
    echo "Deleted RedHandsomeHood.exe from ./gamedata/"
fi

# Check if there are .ogg files in ./gamedata and no .ogg in /assets move them to the appropriate places
if [[ -n "$(ls ./gamedata/*.ogg 2>/dev/null)" ]] && [[ ! -f "./assets/*.ogg" ]]; then
    # Move all .ogg files from ./gamedata to ./assets if there are no .ogg files in ./assets
    mv ./gamedata/*.ogg ./assets/
    echo "Copied ogg files from ./gamedata to ./assets/"
    
    # Copy *.ini files to ./assets
    cp ./gamedata/*.ini ./assets/
    echo "Copied ini files from ./gamedata to ./assets/"
    
    # Zip the contents of ./redhandsomehood.apk including the new .ogg files
    zip -r -0 ./redhandsomehood.apk ./redhandsomehood.apk ./assets/
    echo "Zipped contents to ./redhandsomehood.apk" 
else
    echo ".ogg files already exist in ./assets. Skipping copy and zipping."
fi

cd $GAMEDIR

if [ -f "${controlfolder}/libgl_${CFWNAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

# Check for file existence before trying to manipulate them:
[ -f "./gamedata/data.win" ] && mv gamedata/data.win gamedata/game.droid
[ -f "./gamedata/game.win" ] && mv gamedata/game.win gamedata/game.droid
[ -f "./gamedata/game.unx" ] && mv gamedata/game.unx gamedata/game.droid

# Make sure uinput is accessible so we can make use of the gptokeyb controls
$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "gmloader" -c ./redhandsomehood.gptk &

$ESUDO chmod +x "$GAMEDIR/gmloader"

./gmloader redhandsomehood.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
