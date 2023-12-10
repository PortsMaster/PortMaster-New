#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt

get_controls

GAMEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/sstse"

$ESUDO chmod ugo+rwx -R $GAMEDIR/*
$ESUDO chmod ugo+rwx $GAMEDIR/../*.sh

cd $GAMEDIR

# system
export LD_LIBRARY_PATH=$GAMEDIR/Bin/gl4es:$GAMEDIR/Bin/libs:/usr/lib32:$LD_LIBRARY_PATH

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# gl4es
export SDL_VIDEO_GL_DRIVER=$GAMEDIR/Bin/gl4es/libGL.so.1
export LIBGL_ES=1
export LIBGL_GL=14

$GPTOKEYB "ssam-tse" -c "$GAMEDIR/serioussam.gptk" &
$GAMEDIR/Bin/ssam-tse

$ESUDO kill -9 $(pidof gptokeyb)
unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
$ESUDO systemctl restart oga_events &

# Disable console
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty0
