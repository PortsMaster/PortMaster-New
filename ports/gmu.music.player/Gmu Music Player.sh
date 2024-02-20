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

GAMEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/gmu-music-player"

$ESUDO chmod 777 -R $GAMEDIR/*

cd $GAMEDIR

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

# system
export LD_LIBRARY_PATH=$GAMEDIR/libs:$LD_LIBRARY_PATH

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO rm $GAMEDIR/log.txt
sleep 0.3

$GPTOKEYB "gmu.bin" -c "$GAMEDIR/gmu.gptk" &
./gmu.bin -c gmu.settings.conf 2>&1 | tee -a $GAMEDIR/log.txt

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
unset SDL_GAMECONTROLLERCONFIG
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty0