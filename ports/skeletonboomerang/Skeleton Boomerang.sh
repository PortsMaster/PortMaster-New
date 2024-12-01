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

GAMEDIR="/$directory/ports/skeletonboomerang"

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
  echo "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info." > $CUR_TTY
    echo "PortMaster update required."
  sleep 5
  exit 1
fi

# Patch game
cd "$GAMEDIR"

# If "gamedata/data.win" exists and matches the checksum of the Steam latest or prevamped versions
if [ -f "./gamedata/data.win" ]; then
    checksum=$(md5sum "./gamedata/data.win" | awk '{print $1}')
    
    # Checksum for the Steam latest version
    if [ "$checksum" = "e0e25e5a0053184b61082e666dce9033" ]; then
        mv "./patch/game.apk.latest" "./game.apk"
        mv "./gamedata/data.win" "./gamedata/game.droid"
    # Checksum for the Steam prevamped version
    elif [ "$checksum" = "759c29b9e1ffef1b1436c66869ed0d6b" ]; then
        mv "./patch/game.apk.prevamped" "./game.apk"
        mv "./gamedata/data.win" "./gamedata/game.droid"
    else
        echo "Error: MD5 checksum of data.win does not match any expected version."
	exit 1
    fi
else    
    echo "Missing files in gamedata folder or game has been patched."
fi

# pack audio into apk if not done yet
if [ -n "$(ls ./gamedata/*.ogg 2>/dev/null)" ]; then
    # Move all .ogg files from ./gamedata to ./assets
    mkdir -p ./assets
    mv ./gamedata/*.ogg ./assets/
    echo "Moved .ogg files from ./gamedata to ./assets/"

    # Zip the contents of ./game.apk including the new .ogg files
    zip -r -0 ./game.apk ./assets/
    echo "Zipped contents to ./game.apk"
    rm -Rf "$GAMEDIR/assets/"

    # cleanup if extra files were copied in from steam
    rm -Rf "./gamedata/skeletonboomerang.exe" \
           "./gamedata/"*.dll \
	   "./gamedata/Place game files here"
    echo "Extra game files removed."
fi

$GPTOKEYB "gmloader" &

$ESUDO chmod +x "$GAMEDIR/gmloader"
pm_platform_helper "$GAMEDIR/gmloader"
./gmloader game.apk

pm_finish
