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

GAMEDIR=/$directory/ports/freeciv
CONFDIR="$GAMEDIR/conf"
BINARY=freeciv-sdl2

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

mkdir -p "$GAMEDIR/conf"

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export FREECIV_DATA_PATH="$GAMEDIR/data"
export FREECIV_SAVE_PATH="$GAMEDIR/saves"
export FREECIV_SCENARIO_PATH="$FREECIV_SAVE_PATH/scenarios"

cd $GAMEDIR

$GPTOKEYB "$BINARY" -c ./$BINARY.gptk &
pm_platform_helper "$GAMEDIR/bin/$BINARY"
bin/freeciv-sdl2 -- -f
pm_finish