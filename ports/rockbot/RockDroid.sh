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

GAMEDIR="/$directory/ports/rockbot"

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTPRESET="Name"
export TEXTINPUTINTERACTIVE="Y"

cd "$GAMEDIR/rockdroid"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Extract game files on 1st run
if [ ! -d "$GAMEDIR/rockdroid/games" ]; then
    "$GAMEDIR/7zzs" x "$GAMEDIR/rockdroid/gamedata.7z" -o"$GAMEDIR/rockdroid/"
    sleep 1
    rm -f "$GAMEDIR/rockdroid/gamedata.7z"
fi

bind_directories ~/.rockdroid "$GAMEDIR/conf/.rockdroid"

$GPTOKEYB2 "rockbot.${DEVICE_ARCH}" -c "$GAMEDIR/rockdroid.gptk" &
pm_platform_helper "$GAMEDIR/rockdroid/rockbot.${DEVICE_ARCH}"
./rockbot.${DEVICE_ARCH}

pm_finish
