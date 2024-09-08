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

GAMEDIR="/$directory/ports/minidoom"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_linux"

# We log the execution of the script into log.txt
exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

expected_checksum="66a2399ec3b73b51be1462b416419437"

if [ -f "$GAMEDIR/gamedata/Mini Doom V1.3.exe" ]; then
    # Calculate the MD5 checksum of Mini Doom V1.3.exe
    actual_checksum=$(md5sum "$GAMEDIR/gamedata/Mini Doom V1.3.exe" | awk '{print $1}')

    # Check if the file exists and the checksum matches
    if [ "$actual_checksum" = "$expected_checksum" ]; then
        # Change directory to the specified directory
        cd "$GAMEDIR" || exit 1

        # Use 7zip to extract the .exe file to the destination directory
        "$GAMEDIR/patch/7zzs" x "$GAMEDIR/gamedata/Mini Doom V1.3.exe" -o"$GAMEDIR/gamedata" & pid=$!

        # Wait for the extraction process to complete
        wait $pid

        # Check if the H DOOM 0-4.exe file exists
        if [ -f "$GAMEDIR/gamedata/H DOOM 0-4.exe" ]; then
            # Delete the redundant .exe files
            rm "$GAMEDIR/gamedata/H DOOM 0-4.exe"
            rm "$GAMEDIR/gamedata/Mini Doom V1.3.exe"
            rm "$GAMEDIR/gamedata/Place Mini Doom V1.3.exe here.txt"
        fi
    else
        echo "Error: MD5 checksum of Mini Doom V1.3.exe does not match the expected checksum."
	exit 1
    fi
else
    echo "Missing files in gamedata folder or game has been patched!"
fi

# Check for file existence before trying to manipulate them:
[ -f "./gamedata/data.win" ] && mv gamedata/data.win gamedata/game.droid
[ -f "./gamedata/game.win" ] && mv gamedata/game.win gamedata/game.droid
[ -f "./gamedata/game.unx" ] && mv gamedata/game.unx gamedata/game.droid

# pack audio into apk if not done yet
if [ -n "$(ls ./gamedata/*.ogg 2>/dev/null)" ]; then
    # Move all .ogg files from ./gamedata to ./assets
    mkdir ./assets
    mv ./gamedata/*.ogg ./assets/
    echo "Moved .ogg files from ./gamedata to ./assets/"

    # Zip the contents of ./minidoom.apk including the new .ogg files
    zip -r -0 ./minidoom.apk ./assets/
    echo "Zipped contents to ./minidoom.apk"
    rm -Rf "$GAMEDIR/assets/"
fi

# Make sure uinput is accessible so we can make use of the gptokeyb controls
$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "gmloader" -c ./minidoom.gptk &

$ESUDO chmod +x "$GAMEDIR/gmloader"

./gmloader minidoom.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
