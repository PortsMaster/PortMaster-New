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

GAMEDIR="/$directory/ports/grimstorm"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$GAMEDIR/utils/libs"
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

expected_checksum="f726cba515133d20a29a9fbcfb7e19c8"

if [ -f "$GAMEDIR/gamedata/Grimstorm1.3.2.exe" ]; then
    # Calculate the MD5 checksum of Grimstorm1.3.2.exe
    actual_checksum=$(md5sum "$GAMEDIR/gamedata/Grimstorm1.3.2.exe" | awk '{print $1}')

    # Check if the file exists and the checksum matches
    if [ "$actual_checksum" = "$expected_checksum" ]; then
        # Change directory to the specified directory
        cd "$GAMEDIR" || exit

        # Use 7zip to extract the .exe file to the destination directory
        "$GAMEDIR/patch/7zzs" x "$GAMEDIR/gamedata/Grimstorm1.3.2.exe" -o"$GAMEDIR/gamedata" & pid=$!

        # Wait for the extraction process to complete
        wait $pid

        # Check if the Grimstorm.exe file exists
        if [ -f "$GAMEDIR/gamedata/Grimstorm.exe" ]; then
            # Delete the redundant .exe files
            rm "$GAMEDIR/gamedata/Grimstorm.exe"
            rm "$GAMEDIR/gamedata/Grimstorm1.3.2.exe"
        fi
    else
        echo "Error: MD5 checksum of Grimstorm1.3.2.exe does not match the expected checksum."
    fi
else
    echo "Error: Missing files in gamedata folder!"
fi


# Check for file existence before trying to manipulate them:
[ -f "./gamedata/data.win" ] && mv gamedata/data.win gamedata/game.droid
[ -f "./gamedata/game.win" ] && mv gamedata/game.win gamedata/game.droid
[ -f "./gamedata/game.unx" ] && mv gamedata/game.unx gamedata/game.droid

# Make sure uinput is accessible so we can make use of the gptokeyb controls
$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "gmloader" &

$ESUDO chmod +x "$GAMEDIR/gmloader"

./gmloader grimstorm.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0

