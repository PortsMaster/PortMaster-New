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

GAMEDIR="/$directory/ports/f2bgl"

cd $GAMEDIR

export LD_LIBRARY_PATH="$GAMEDIR/lib:$LD_LIBRARY_PATH"
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "f2bgl" -c "$GAMEDIR/f2bgl.gptk" &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" LIBGL_FB=2 LIBGL_ES=2 LIBGL_GL=21 LIBGL_NOTEST=1 ./f2bgl 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
unset LD_LIBRARY_PATH
printf "\033c" >> /dev/tty1
