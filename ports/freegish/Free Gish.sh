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

GAMEDIR=/$directory/ports/freegish
CONFDIR="$GAMEDIR/conf"
BINARY=freegish

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

mkdir -p "$GAMEDIR/conf"

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTINTERACTIVE="Y" 

bind_directories ~/.freegish $GAMEDIR/conf/.freegish

cd $GAMEDIR

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

sed -i "s/screenwidth=[0-9]*/screenwidth=${DISPLAY_WIDTH}/;s/screenheight=[0-9]*/screenheight=${DISPLAY_HEIGHT}/" conf/.freegish/config.txt

$GPTOKEYB "$BINARY"  -c ./$BINARY.gptk &
pm_platform_helper "$GAMEDIR/$BINARY"
./$BINARY
pm_finish