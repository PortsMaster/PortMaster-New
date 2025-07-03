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

GAMEDIRNAME="opentyrian2000"
GAMEDATADIRNAME="gamedata"
GAMEDIR="/$directory/ports/$GAMEDIRNAME"
CONFDIR="$GAMEDIR/conf/"
BINARY=opentyrian2000

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export XDG_DATA_HOME="$CONFDIR"
export TEXTINPUTINTERACTIVE="Y" 

mkdir -p "$GAMEDIR/conf/.$GAMEDIRNAME"
bind_directories ~/.$GAMEDIRNAME $GAMEDIR/conf/.$GAMEDIRNAME

cd $GAMEDIR

$GPTOKEYB "$BINARY" -c ./$BINARY.gptk &
pm_platform_helper "$GAMEDIR/$BINARY"
./$BINARY.${DEVICE_ARCH} -t $GAMEDATADIRNAME -j

pm_finish
