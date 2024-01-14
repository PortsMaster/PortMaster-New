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

GAMEDIR=/$directory/ports/starcatcher
cd $GAMEDIR

export FRT_NO_EXIT_SHORTCUTS=FRT_NO_EXIT_SHORTCUTS


$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "frt_3.5" -c "./starcatcher.gptk" &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./frt_3.5 --main-pack starcatcher.pck
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0

