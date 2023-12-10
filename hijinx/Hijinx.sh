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

GAMEDIR=/$directory/ports/hijinx/
cd $GAMEDIR

export FRT_NO_EXIT_SHORTCUTS=FRT_NO_EXIT_SHORTCUTS


$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "frt_3.2.3" -c "./godot.gptk" &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./frt_3.2.3 --main-pack HijinxEE.pck
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0

