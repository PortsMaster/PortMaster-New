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
export PORT_32BIT="Y"

get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"


GAMEDIR="/$directory/ports/mezzer"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_windows"

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Permissions
$ESUDO chmod +x "$GAMEDIR/gmloader"

# check if we have new enough version of PortMaster that contains xdelta3
if [ ! -f "$controlfolder/xdelta3" ]; then
  pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info." > /dev/tty0
  sleep 5
  exit 1
fi

# Patch game
cd "$GAMEDIR"

if [ -f "$GAMEDIR/Mezzer.exe" ]; then
    # Calculate the MD5 checksum of Mezzer.exe
    actual_checksum=$(md5sum "$GAMEDIR/Mezzer.exe" | awk '{print $1}')

    # Check if the file exists and the checksum matches
    if [ "$actual_checksum" = "673538d6d454fc6563b184bf099f3943" ]; then
        # Change directory to the specified directory
        cd "$GAMEDIR" || exit

        # Use 7zip to extract the .exe file to the destination directory
        "$GAMEDIR/tools/7zzs" x "$GAMEDIR/Mezzer.exe" -o"$GAMEDIR/gamedata" & pid=$!

        # Wait for the extraction process to complete
        wait $pid

        # Check if Mezzer.exe file exists
        if [ -f "$GAMEDIR/gamedata/Mezzer.exe" ]; then
            # Delete the files
            rm -f "$GAMEDIR/gamedata/Mezzer.exe"
            rm -f "$GAMEDIR/gamedata/D3DX9_43.dll"
	    rm -f "$GAMEDIR/Mezzer.exe"
        fi
    else
        pm_message "Error: MD5 checksum of Mezzer.exe does not match the expected checksum."
        exit 1
    fi
else
    pm_message "Mezzer.exe not detected in /mezzer"
fi

# If "gamedata/data.win" exists and matches the checksum steam version
if [ -f "./gamedata/data.win" ]; then
    checksum=$(md5sum "./gamedata/data.win" | awk '{print $1}')
    # Checksum for the data.win
    if [ "$checksum" = "02cbf4cf97b55391e3c6105cfd70fa11" ]; then
        pm_message "data.win is being patched..." && \
        $ESUDO $controlfolder/xdelta3 -d -s gamedata/data.win -f ./patch/mezzer.xdelta gamedata/game.droid && \
        rm gamedata/data.win
    else
        pm_message "Error: MD5 checksum of data.win does not match any expected version."
        exit 1
    fi
else    
    pm_message "data.win not in gamedata folder or game has been patched."
fi

# Check if there are any .ogg files in the ./gamedata directory
if [ -n "$(ls ./gamedata/*.ogg 2>/dev/null)" ]; then
    # Create the ./assets directory if it doesn't exist
    mkdir -p ./assets

    # Move all .ogg files from ./gamedata to ./assets
    mv ./gamedata/*.ogg ./assets/ 2>/dev/null
    pm_message "Moved .ogg files from ./gamedata to ./assets/"

    # Zip the contents of ./mezzer.apk including the new audio files
    zip -r -0 ./mezzer.apk ./assets/
    pm_message "Zipped contents to ./mezzer.apk"

    # Remove the assets directory
    rm -Rf ./assets/
fi

$GPTOKEYB "gmloader" &

$ESUDO chmod +x "$GAMEDIR/gmloader"
pm_platform_helper "$GAMEDIR/gmloader"
./gmloader mezzer.apk

pm_finish
printf "\033c" > /dev/tty0
