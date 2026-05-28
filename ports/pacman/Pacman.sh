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

GAMEDIR="/$directory/ports/pacman"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

BINARY="pacman.${DEVICE_ARCH}"
if [[ $DISPLAY_WIDTH -lt "740" ]] && [[ $DISPLAY_HEIGHT == "480" ]]; then
    if [[ "${DEVICE_CPU^^}" == "RK3326" ]] || [[ "${DEVICE_CPU^^}" == "H700" ]]; then
      BINARY="pacman_prfhak.aarch64"
    fi
fi

$ESUDO chmod +x "$GAMEDIR/$BINARY"

cd $GAMEDIR

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$GPTOKEYB "$BINARY" -c "$GAMEDIR/pacman.gptk" &
pm_platform_helper "$GAMEDIR/$BINARY"
./$BINARY

pm_finish
