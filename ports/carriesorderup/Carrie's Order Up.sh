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

GAMEDIR="/$directory/ports/carriesorderup"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$GAMEDIR/utils/libs"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"

# We log the execution of the script into log.txt
exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Patch Game
cd "$GAMEDIR"

# check if we have new engough version of PortMaster that contains xdelta3
if [ ! -f "$controlfolder/xdelta3" ]; then
  echo "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info." > /dev/tty0
  sleep 5
  exit 1
fi

# Check if CarriesOrderUp.exe exists in the /gamedata folder and delete it if it does
if [ -f "./gamedata/CarriesOrderUp.exe" ]; then
    rm ./gamedata/CarriesOrderUp.exe
    echo "Deleted CarriesOrderUp.exe from ./gamedata/"
fi

# Check if "gamedata/data.win" exists and its MD5 hash is "71803908df80ed78778e24a9f5340e54", and if display resolution is one of the specified resolutions
if [ -f "./gamedata/data.win" ]; then
    file_md5=$(md5sum "./gamedata/data.win" | awk '{print $1}')
    if [ "$file_md5" = "71803908df80ed78778e24a9f5340e54" ]; then
        if [[ "${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}" == "720x720" ]]; then
            $ESUDO $controlfolder/xdelta3 -d -s gamedata/data.win -f ./patch/720x720.xdelta gamedata/data.win
        elif [[ "${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}" == "640x480" ]]; then
            $ESUDO $controlfolder/xdelta3 -d -s gamedata/data.win -f ./patch/640x480.xdelta gamedata/data.win
        elif [[ "${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}" == "854x480" ]]; then
            $ESUDO .$controlfolder/xdelta3 -d -s gamedata/data.win -f ./patch/854x480.xdelta gamedata/data.win
        elif [[ "${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}" == "960x544" ]]; then
            $ESUDO .$controlfolder/xdelta3 -d -s gamedata/data.win -f ./patch/960x544.xdelta gamedata/data.win
        else
            # Handle other resolutions
            echo "Resolution is not one of the specified resolutions"
        fi
    fi
fi

# Check if there are .ogg files in ./gamedata and move them to the appropriate places
 if [ -n "$(ls ./gamedata/*.ogg 2>/dev/null)" ]; then
    # Move all .ogg files from ./gamedata to ./assets
    mv ./gamedata/*.ogg ./assets/
    echo "Moved ogg files from ./gamedata to ./assets/"

    # Copy *.ini files to ./assets
    mv ./gamedata/*.ini ./assets/
    echo "Copied ini files from ./gamedata to ./assets/"

    # Copy *.dll files to ./assets
    mv ./gamedata/*.dll ./assets/
    echo "Copied dll files from ./gamedata to ./assets/"
    
    # Zip the contents of ./carriesorderup.apk including the new .ogg files
    zip -r -0 ./carriesorderup.apk ./carriesorderup.apk ./assets/
    echo "Zipped contents to ./carriesorderup.apk"

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

$GPTOKEYB "gmloader" -c ./carriesorderup.gptk &

$ESUDO chmod +x "$GAMEDIR/gmloader"

./gmloader carriesorderup.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0

