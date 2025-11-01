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

cd "$GAMEDIR/rockbot"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO chmod +x "$GAMEDIR/rockbot/rockbot.${DEVICE_ARCH}"
$ESUDO chmod +x "$GAMEDIR/7zzs.${DEVICE_ARCH}"

# Extract game files on 1st run
if [ ! -d "$GAMEDIR/rockbot/games" ]; then
    "$GAMEDIR/7zzs.${DEVICE_ARCH}" x "$GAMEDIR/rockbot/gamedata.7z" -o"$GAMEDIR/rockbot/"
    sleep 1
    rm -f "$GAMEDIR/rockbot/gamedata.7z"
fi

bind_directories ~/.rockbot "$GAMEDIR/conf/.rockbot"

$GPTOKEYB "rockbot.${DEVICE_ARCH}" -c "$GAMEDIR/rockbot.gptk" &
pm_platform_helper "$GAMEDIR/rockbot/rockbot.${DEVICE_ARCH}"
./rockbot.${DEVICE_ARCH}

pm_finish
