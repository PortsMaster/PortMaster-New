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

GAMEDIR="/$directory/ports/flipclock"


> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

CONFDIR="$GAMEDIR/conf/"
export XDG_CONFIG_HOME="$CONFDIR"

cd $GAMEDIR

$ESUDO chmod +x $GAMEDIR/flipclock.${DEVICE_ARCH}

$GPTOKEYB flipclock.${DEVICE_ARCH} -c flipclock.gptk &
pm_platform_helper "flipclock.${DEVICE_ARCH}"
./flipclock.${DEVICE_ARCH} -f ./dists/flipclock.ttf

pm_finish

