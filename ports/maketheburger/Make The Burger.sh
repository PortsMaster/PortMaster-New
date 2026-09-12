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
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/maketheburger"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

if [ ! -f "$GAMEDIR/gamedata/data.win" ] && [ ! -f "$GAMEDIR/data.win" ] && [ ! -f "$GAMEDIR/assets/data.win" ]; then
    pm_message "Game file not found. Place your own legitimate data.win (from Steam, depot 1358612) into maketheburger/gamedata/"
    sleep 15
    exit 1
fi

PATCH_VERSION="1"
if [ ! -f "$GAMEDIR/gamedata/.patched_complete" ] || [ "$(cat "$GAMEDIR/gamedata/.patched_complete")" != "$PATCH_VERSION" ]; then
    export PATCHER_FILE="$GAMEDIR/patch/patch.bash"
    export PATCHER_GAME="Make The Burger"
    export PATCHER_TIME="1 minute"
    export controlfolder
    export ESUDO
    export DEVICE_RAM

    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        $ESUDO chmod a+x "$GAMEDIR/patch/patch.bash"
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb2) 2>/dev/null
    else
        echo "This port requires the latest version of PortMaster."
        sleep 5
        exit 1
    fi

    if [ ! -f "$GAMEDIR/gamedata/.patched_complete" ]; then
        echo "Patching failed"
        sleep 5
        exit 1
    fi
fi

[ -f "$GAMEDIR/maketheburger.port" ] || { echo "maketheburger.port missing after patching"; sleep 5; exit 1; }

cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64

$GPTOKEYB2 "gmloadernext.aarch64" -c "$GAMEDIR/controls.ini" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

pm_finish
