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
source $controlfolder/device_info.txt

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR=/$directory/ports/axecop
CONFDIR="$GAMEDIR/conf/"
DATAFILE=axecop.rpg

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

mkdir -p "$GAMEDIR/conf"

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTINTERACTIVE="Y"
export XDG_DATA_HOME="$CONFDIR"

cd $GAMEDIR

# Rename any .rpg file found to the DATAFILE variable
rpg_file=$(find "$GAMEDIR" -name "*.rpg" | head -n 1)
if [ -n "$rpg_file" ]; then
  mv "$rpg_file" "$GAMEDIR/axecop.rpg"
  DATAFILE="axecop.rpg"
else
  echo "No .rpg file found in $GAMEDIR"
  exit 1
fi

$GPTOKEYB "ohrrpgce-game" -c ./axecop.gptk &

"./ohrrpgce-game" $DATAFILE -f

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
