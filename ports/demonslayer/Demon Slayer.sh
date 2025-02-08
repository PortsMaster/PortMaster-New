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
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/demonslayer"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/assets/"
export GMLOADER_PLATFORM="os_linux"

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [ -f "assets/data.win" ]; then
    checksum=$(md5sum "assets/data.win" | awk '{print $1}')
    if [ "$checksum" = "ad4db39b3e802c3888a6b27a2f459be6" ]; then
        $ESUDO $controlfolder/xdelta3 -d -s "assets/data.win" -f "./patch/patch.xdelta3" "assets/game.droid" && \
        rm "assets/data.win"
    fi
fi

[ -e "./assets/data.win" ] && mv ./assets/data.win ./assets/game.droid

if [ -f ./assets/game.droid ]; then
    mkdir -p "$GAMEDIR/assets"
    mv "$GAMEDIR/assets/game.droid" "$GAMEDIR/assets/"
    sleep 1
    cd $GAMEDIR
    zip -r -0 $GAMEDIR/demonslayer.port assets
    rm -rf "$GAMEDIR/assets"
fi

$GPTOKEYB "gmloader" -c "./demonslayer.gptk" &
$ESUDO chmod +x "$GAMEDIR/gmloader"
pm_platform_helper "$GAMEDIR/gmloader"
./gmloader demonslayer.port

pm_finish
