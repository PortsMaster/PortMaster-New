#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "/roms/ports" ]; then
  controlfolder="/roms/ports/PortMaster"
 elif [ -d "/roms2/ports" ]; then
  controlfolder="/roms2/ports/PortMaster"
else
  controlfolder="/storage/roms/ports/PortMaster"
fi

source $controlfolder/control.txt

get_controls

GAMEDIR=/$directory/ports/srb2kart

cd $GAMEDIR

if [[ $LOWRES=="Y" ]]; then
  swidth="480"
  sheight="320"
else
  swidth="640"
  sheight="480"
fi

$ESUDO chmod 666 /dev/uinput
# $GPTOKEYB "srb2kart" -c "srb2kart.gptk" &
$GPTOKEYB "srb2kart" &
LD_LIBRARY_PATH="$PWD/libs" SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./srb2kart 2>&1 | tee ./log.txt 
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1