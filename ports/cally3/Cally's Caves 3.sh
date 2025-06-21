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
  
GAMEDIR="/$directory/ports/cally3"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/saves/"
export GMLOADER_PLATFORM="os_linux"

cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

[ -e "./assets/data.win" ] && mv ./assets/data.win ./assets/game.droid

if [ -f ./assets/game.droid ]; then
    mkdir -p "$GAMEDIR/assets"
    mv "$GAMEDIR/assets/game.droid" "$GAMEDIR/assets/"
    sleep 1
    cd $GAMEDIR
    zip -r -0 $GAMEDIR/cally3.port assets
    rm -rf "$GAMEDIR/assets"
fi

$GPTOKEYB "gmloader" &
pm_platform_helper "$GAMEDIR/gmloader"
./gmloader cally3.port

pm_finish
