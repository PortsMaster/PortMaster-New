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

GAMEDIR=/$directory/ports/planetmerge/
CONFDIR="$GAMEDIR/conf/"

mkdir -p "$GAMEDIR/conf"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1


export XDG_DATA_HOME="$CONFDIR"
export XDG_CONFIG_HOME="$CONFDIR"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$GPTOKEYB "planets.${DEVICE_ARCH}" &

pm_platform_helper "$GAMEDIR/planets.${DEVICE_ARCH}"

./planets.${DEVICE_ARCH}

pm_finish

