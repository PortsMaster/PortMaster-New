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

GAMEDIR=/$directory/ports/xooxenoxafari
CONFDIR="$GAMEDIR/conf/"
DATAFILE=xeno.rpg # demo file

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

mkdir -p "$GAMEDIR/conf"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTINTERACTIVE="Y"
export XDG_DATA_HOME="$CONFDIR"

cd $GAMEDIR

# Check if xoo.rpg exists in; change DATAFILE to xoo.rpg if it exists
if [ -f "./xoo.rpg" ]; then
  DATAFILE=xoo.rpg # full game file
fi

$GPTOKEYB "ohrrpgce-game" -c ./xooxenoxafari.gptk &
pm_platform_helper "$GAMEDIR/ohrrpgce-game"
"./ohrrpgce-game" $DATAFILE -f

pm_finish
