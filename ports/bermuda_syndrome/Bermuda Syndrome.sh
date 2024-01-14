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

GAMEDIR="/$directory/ports/bermuda"
cd $GAMEDIR

$ESUDO chmod 666 /dev/tty1
printf "\033c" >> /dev/tty1

if [ $LOWRES == 'N' ]; then
  $ESUDO chmod 666 /dev/uinput
  $GPTOKEYB "bs" &
  SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./bs --fullscreen --widescreen=4:3 --datapath="$GAMEDIR/DATA" 2>&1 | tee $GAMEDIR/log.txt
else
  printf "This game requires 640x480 resolution" >> /dev/tty1
  sleep 5
fi
printf "\033c" >> /dev/tty1
