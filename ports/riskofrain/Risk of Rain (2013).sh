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

# PortMaster info
source $controlfolder/control.txt
source $controlfolder/device_info.txt
GAMEDIR=/$directory/ports/riskofrain
get_controls

# Enable logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="/usr/lib:/usr/lib32:/$GAMEDIR/lib:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/"
export GMLOADER_PLATFORM="os_windows"
export PORT_32BIT="Y"
cd "$GAMEDIR"

# Delete unnecessary files
files_to_delete=(
  "D3DX9_43.dll"
  "GMFile.dll"
  "GMIni.dll"
  "GMResource.dll"
  "GMXML.dll"
  "MyMod.gamelog.txt"
  "MyMod.temp"
  "Risk of Rain.exe"
  "steam_api.dll"
  "steam_autocloud.vdf"
)

for file in "${files_to_delete[@]}"; do
  if [ -f "$file" ]; then
    rm "$file"
    echo "Deleted $file"
  else
    echo "$file not found"
  fi
done

# Check if there are any .ogg files in the current directory
if [ -n "$(ls ./*.ogg 2>/dev/null)" ]; then
    # Create the assets directory if it doesn't exist
    mkdir -p ./assets

    # Move all .ogg files from the current directory to ./assets
    mv ./*.ogg ./assets/
    echo "Moved .ogg files to ./assets/"

    # Zip the contents of ./assets into ./game.apk without compression
    zip -r -0 ./game.apk ./assets/
    echo "Zipped contents to ./game.apk"

    # Delete the assets directory after processing
    rm -rf ./assets
    echo "Deleted assets directory"
else
    echo "No .ogg files found"
fi

if [ -f "data.win" ]; then
    checksum=$(md5sum "data.win" | awk '{print $1}')
    if [ "$checksum" = "d32c0d93bfc23b242fe7fca90f1d07ef" ]; then

        # Move Prefs.ini from the conf folder and overwrite it in the current folder
        ini_file="conf/Prefs.ini"
        if [ -f "$ini_file" ]; then
            mv -f "$ini_file" "./Prefs.ini"
        fi

        # Apply the patch
        $ESUDO $controlfolder/xdelta3 -d -s "data.win" -f "./patch/riskofrain.xdelta" "game.droid" && \
        rm "data.win"
    fi
fi

$ESUDO chmod 666 /dev/uinput
$ESUDO chmod +x "$GAMEDIR/gmloadernext"
$GPTOKEYB "gmloadernext" -c "./riskofrain.gptk" &
./gmloadernext game.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty0
