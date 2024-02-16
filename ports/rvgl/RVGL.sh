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

GAMEDIR=/$directory/ports/rvgl

cd $GAMEDIR

export TEXTINPUTINTERACTIVE="Y"

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "rvgl.arm64" -c "./rvgl.gptk" &
$GAMEDIR/rvgl
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1