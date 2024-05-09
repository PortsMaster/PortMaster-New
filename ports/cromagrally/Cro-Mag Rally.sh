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

get_controls

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

GAMEDIR=/$directory/ports/cromagrally
exec > >(tee "$GAMEDIR/log.txt") 2>&1

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

if [ "$LIBGL_FB" != "" ]; then
export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es.aarch64/libGL.so.1"
fi 

cd $GAMEDIR

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "CroMagRally" &
./CroMagRally

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
