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

GAMEDIR="/$directory/ports/grelox"
TOOLDIR="$GAMEDIR/tools"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export PATH="$TOOLDIR:$PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_linux"

swapabxy() {

    if [ "$CFW_NAME" == "knulli" ] && [ -f "$SDL_GAMECONTROLLERCONFIG_FILE" ];then
        cat "$SDL_GAMECONTROLLERCONFIG_FILE" | swapabxy.py > "$GAMEDIR/gamecontrollerdb_swapped.txt"
          export SDL_GAMECONTROLLERCONFIG_FILE="$GAMEDIR/gamecontrollerdb_swapped.txt"
    else
        export SDL_GAMECONTROLLERCONFIG="`echo "$SDL_GAMECONTROLLERCONFIG" | swapabxy.py`"
    fi
}

if [ -f "$GAMEDIR/swapabxy.txt" ]; then
    swapabxy
fi

cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

$GPTOKEYB "gmloader" -c "./game.gptk" &
chmod +x ./gmloader
pm_platform_helper "$GAMEDIR/gmloader"
./gmloader grelox.port

pm_finish
