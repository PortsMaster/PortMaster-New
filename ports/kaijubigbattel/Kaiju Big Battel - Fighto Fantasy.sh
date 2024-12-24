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

GAMEDIR="/$directory/ports/kaijubigbattel"
CONFDIR="$GAMEDIR/conf/"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

mkdir -p "$GAMEDIR/conf"

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTINTERACTIVE="Y"
export XDG_DATA_HOME="$CONFDIR"

cd $GAMEDIR

bind_directories "$HOME/.ohrrpgce" "$CONFDIR"

# Check if kaiju.rpg or kaijudemo.rpg exists
if [ -f "kaiju.rpg" ]; then
  DATAFILE="kaiju.rpg"
elif [ -f "kaijudemo.rpg" ]; then
  DATAFILE="kaijudemo.rpg"
else
  echo "Neither kaiju.rpg nor kaijudemo.rpg found."
  exit 1
fi

$GPTOKEYB "ohrrpgce-game" -c ./kaijubigbattel.gptk &
pm_platform_helper "$GAMEDIR/ohrrpgce-game"
"./ohrrpgce-game" $DATAFILE -f

pm_finish
