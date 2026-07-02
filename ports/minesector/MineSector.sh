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

GAMEDIR="/$directory/ports/minesector"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO chmod +x "$GAMEDIR/minesector.${DEVICE_ARCH}"

if [[ "${CFW_NAME^^}" == "MUOS" ]] && [[ "$DEVICE_ARCH" == "aarch64" ]]; then
  $ESUDO rm "$GAMEDIR/libs.aarch64/libasound.so.2"
fi

$GPTOKEYB "minesector.${DEVICE_ARCH}" -c "$GAMEDIR/minesector.gptk" &
pm_platform_helper "$GAMEDIR/minesector.${DEVICE_ARCH}"
./minesector.${DEVICE_ARCH}

pm_finish
