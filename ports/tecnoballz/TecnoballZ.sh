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

GAMEDIR="/$directory/ports/tecnoballz"
CONFDIR="$GAMEDIR/conf"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [ ! -f "$controlfolder/7zzs.${DEVICE_ARCH}" ]; then
    pm_message "this port requires the latest portmaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
fi

# Extract game files on 1st run
if [ ! -d "$GAMEDIR/data" ]; then
    "$controlfolder/7zzs.${DEVICE_ARCH}" x "$GAMEDIR/gamedata.7z" -o"$GAMEDIR/"
    sleep 1
fi

bind_directories ~/.config/tlk-games "$GAMEDIR/conf/tlk-games"

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO cp "$GAMEDIR/tecnoballz.${DEVICE_ARCH}" "$GAMEDIR/tecnoballz"

$ESUDO chmod +x "$GAMEDIR/tecnoballz"

cd $GAMEDIR

$GPTOKEYB "tecnoballz" -c "./tecnoballz.gptk.$ANALOG_STICKS" &
pm_platform_helper "$GAMEDIR/tecnoballz"
./tecnoballz

pm_finish
