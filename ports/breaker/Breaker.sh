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
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

$ESUDO chmod 666 /dev/tty0

GAMEDIR=/$directory/ports/breaker

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$GAMEDIR/utils/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"

cd $GAMEDIR

expected_checksum="d6e222cf37e2e49ad8b648efc2cc6cf5"

if [ -f "$GAMEDIR/gamedata/BREAKER.exe" ]; then
    # Calculate the MD5 checksum of BREAKER.exe
    actual_checksum=$(md5sum "$GAMEDIR/gamedata/BREAKER.exe" | awk '{print $1}')

    # Check if the file exists and the checksum matches
    if [ "$actual_checksum" = "$expected_checksum" ]; then
        # Change directory to the specified directory
        cd "$GAMEDIR" || exit

        # Use 7zip to extract the .exe file to the destination directory
        "$GAMEDIR/patch/7zzs" x "$GAMEDIR/gamedata/BREAKER.exe" -o"$GAMEDIR/gamedata" & pid=$!

        # Wait for the extraction process to complete
        wait $pid

        # Check if the BREAKER v1_5.exe file exists
        if [ -f "$GAMEDIR/gamedata/BREAKER v1_5.exe" ]; then
            # Delete the redundant .exe files
            rm "$GAMEDIR/gamedata/BREAKER.exe"
            rm "$GAMEDIR/gamedata/BREAKER v1_5.exe"
        fi
    else
        echo "Error: MD5 checksum of BREAKER.exe does not match the expected checksum."
        exit 1 
   fi
else
    echo "Missing files in gamedata folder OR game has been patched!"
fi


# pack audio into apk if not done yet
if [ -n "$(ls ./gamedata/*.ogg 2>/dev/null)" ]; then
    # Move all .ogg files from ./gamedata to ./assets
    mkdir ./assets
    mv ./gamedata/*.ogg ./assets/
    echo "Moved .ogg files from ./gamedata to ./assets/"

    # Zip the contents of ./breaker.apk including the new .ogg files
    zip -r -0 ./breaker.apk ./assets/
    echo "Zipped contents to ./breaker.apk"
    rm -Rf "$GAMEDIR/assets/"

    # cleanup if extra files were copied in from steam
    rm -Rf $GAMEDIR/gamedata/*.dll
fi

[ -f "./gamedata/data.win" ] && mv gamedata/data.win gamedata/game.droid
[ -f "./gamedata/game.unx" ] && mv gamedata/game.win gamedata/game.droid

$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "gmloader" &

$ESUDO chmod +x "$GAMEDIR/gmloader"

./gmloader breaker.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
