#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/device_info.txt

get_controls

GAMEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/oquonie"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

cd $GAMEDIR
$GPTOKEYB "uxnemu" -c "$GAMEDIR/oquonie.gptk" &
./uxnemu oquonie.rom

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
unset SDL_GAMECONTROLLERCONFIG
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty0

