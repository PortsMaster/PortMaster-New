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

GAMEDIR=/$directory/ports/hawkthorne
cd $GAMEDIR

export LOVE_GRAPHICS_USE_OPENGLES=1

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "love" &
LD_LIBRARY_PATH="$PWD/libs" ./love hawkthorne.love 2>&1 | tee -a ./log.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0