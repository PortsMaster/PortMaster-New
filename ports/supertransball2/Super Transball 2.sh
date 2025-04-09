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

GAMEDIR=/$directory/ports/supertransball2
CONFDIR="$GAMEDIR/conf/"
BINARY=supertransball2

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

mkdir -p "$GAMEDIR/conf"

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export XDG_DATA_HOME="$CONFDIR"
export SUPERTRANSBALL2_CONFIG_DIR=$GAMEDIR/data/
export SUPERTRANSBALL2_DATA_DIR=$GAMEDIR/data/

bind_directories ~/.supertransball2 $GAMEDIR/conf/.supertransball2

cd $GAMEDIR

$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "$BINARY" -c ./$BINARY.gptk &
./$BINARY

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
