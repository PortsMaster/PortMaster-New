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

GAMEDIR="/$directory/ports/spacemothdx"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_windows"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

$ESUDO chmod +x "$GAMEDIR/gmloader"
$ESUDO chmod +x "$GAMEDIR/libs/7zzs"

if [ -f "./gamedata/Space Moth DX.exe" ]; then
    # Extract the executable contents using 7zzs
    if ./libs/7zzs x "./gamedata/Space Moth DX.exe" -o"./gamedata/" -aoa; then
        # If extraction succeeds, remove the original executable
        rm "./gamedata/Space Moth DX.exe" || exit 1
    else
        # Exit with an error if the extraction fails
        echo "Error: Failed to extract Space Moth DX.exe"
        exit 1
    fi
fi

if [ -f "gamedata/data.win" ]; then
    checksum=$(md5sum "gamedata/data.win" | awk '{print $1}')
    if [ "$checksum" = "e8e2072599598065f7a305b02b420dce" ]; then
        $ESUDO $controlfolder/xdelta3 -d -s "gamedata/data.win" -f "./patch/patch.xdelta" "gamedata/game.droid" && \
        rm "gamedata/data.win"
    fi
fi

if [ -n "$(ls ./gamedata/*.ogg 2>/dev/null)" ]; then
    # Move all .ogg files from ./gamedata to ./assets
    mkdir -p ./assets
    mv ./gamedata/*.ogg ./assets/ || exit 1

    zip -r -0 ./spacemoth.apk ./assets/ || exit 1
    rm -Rf "$GAMEDIR/assets/" || exit 1
fi

$GPTOKEYB "gmloader" &
pm_platform_helper "$GAMEDIR/gmloader"
./gmloader spacemoth.apk

pm_finish
