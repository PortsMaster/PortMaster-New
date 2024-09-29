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

GAMEDIR="/$directory/ports/savingprincess"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_windows"

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Permissions
$ESUDO chmod 666 /dev/uinput
$ESUDO chmod +x "$GAMEDIR/gmloader"

cd $GAMEDIR

#Patch Game

if [ -f "$GAMEDIR/gamedata/Saving Princess.exe" ]; then
    # Calculate the MD5 checksum of Saving Princess.exe
    actual_checksum=$(md5sum "$GAMEDIR/gamedata/Saving Princess.exe" | awk '{print $1}')

    # Check if the file exists and the checksum matches
    if [ "$actual_checksum" = "35a111d0149fae1f04b7b3fea42c5319" ]; then
        # Change directory to the specified directory
        cd "$GAMEDIR" || exit

        # Use 7zip to extract the .exe file to the destination directory
        "$GAMEDIR/tools/7zzs" x "$GAMEDIR/gamedata/Saving Princess.exe" -o"$GAMEDIR/gamedata" & pid=$!

        # Wait for the extraction process to complete
        wait $pid

        # Check if Saving Princess v0_8.exe file exists
        if [ -f "$GAMEDIR/gamedata/Saving Princess v0_8.exe" ]; then
            # Delete the redundant .exe files
            rm -f "$GAMEDIR/gamedata/Saving Princess v0_8.exe"
            rm -f "$GAMEDIR/gamedata/Saving Princess.exe"
	    rm -f "$GAMEDIR/gamedata/D3DX9_43.dll"
        fi
    else
        echo "Error: MD5 checksum of Saving Princess.exe does not match the expected checksum."
    fi
else
    echo "Saving Princess.exe not detected in /gamedata"
fi

if [ -f "$GAMEDIR/gamedata/Saving Princess - DEMO - Windows.exe" ]; then
    # Calculate the MD5 checksum of Saving Princess - DEMO - Windows.exe
    actual_checksum_demo=$(md5sum "$GAMEDIR/gamedata/Saving Princess - DEMO - Windows.exe" | awk '{print $1}')

    # Check if the file exists and the checksum matches
    if [ "$actual_checksum_demo" = "26f6e1a57b1ed89a7554ced8bd58f2bb" ]; then
        # Change directory to the specified directory
        cd "$GAMEDIR" || exit

        # Use 7zip to extract the .exe file to the destination directory
        "$GAMEDIR/tools/7zzs" x "$GAMEDIR/gamedata/Saving Princess - DEMO - Windows.exe" -o"$GAMEDIR/gamedata" & pid=$!

        # Wait for the extraction process to complete
        wait $pid

        # Check if Saving Princess - DEMO.exe file exists
        if [ -f "$GAMEDIR/gamedata/Saving Princess - DEMO.exe" ]; then
            # Delete the redundant .exe files
            rm -f "$GAMEDIR/gamedata/Saving Princess - DEMO.exe"
            rm -f "$GAMEDIR/gamedata/Saving Princess - DEMO - Windows.exe"
	    rm -f "$GAMEDIR/gamedata/D3DX9_43.dll"
        fi
    else
        echo "Error: MD5 checksum of Saving Princess - DEMO - Windows.exe does not match the expected checksum."
	exit 1
    fi
else
    echo "Saving Princess - DEMO - Windows.exe not detected in /gamedata"
fi

# Check for file existence before trying to manipulate them:
[ -f "./gamedata/data.win" ] && mv gamedata/data.win gamedata/game.droid

# Check if there are any .ogg or .mp3 files in the ./gamedata directory
if [ -n "$(ls ./gamedata/*.ogg 2>/dev/null)" ]; then
    # Create the ./assets directory if it doesn't exist
    mkdir -p ./assets

    # Move all .ogg files from ./gamedata to ./assets
    mv ./gamedata/*.ogg ./assets/ 2>/dev/null
    echo "Moved .ogg files from ./gamedata to ./assets/"

    # Zip the contents of ./savingprincess.apk including the new audio files
    zip -r -0 ./savingprincess.apk ./assets/
    echo "Zipped contents to ./savingprincess.apk"

    # Remove the assets directory
    rm -Rf ./assets/
fi

# Splash Screen 
if [ -f "$GAMEDIR/gamedata/splash.png" ]; then
    # Calculate the MD5 checksum of gamedata/splash.png
    splash_checksum=$(md5sum "$GAMEDIR/gamedata/splash.png" | awk '{print $1}')

    # Check if the checksum does not match the expected value
    if [ "$splash_checksum" != "53aa45e0edcdabcb8a8c50fd3a58970e" ]; then
        # Copy the new splash.png from the main directory to gamedata
        cp "$GAMEDIR/splash.png" "$GAMEDIR/gamedata/splash.png"
    fi
fi

$GPTOKEYB "gmloader" &

$ESUDO chmod +x "$GAMEDIR/gmloader"

./gmloader savingprincess.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
