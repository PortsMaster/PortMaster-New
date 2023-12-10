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

GAMEDIR=/$directory/ports/tiny-crate
cd $GAMEDIR

export FRT_NO_EXIT_SHORTCUTS=FRT_NO_EXIT_SHORTCUTS


$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "frt_3.5" -c "./tiny.gptk" &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./frt_3.5 --main-pack Tiny-Crate.pck
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0

