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

GAMEDIR=/$directory/ports/hex-a-hop
cd $GAMEDIR

$ESUDO rm -rf ~/.hex-a-hop
ln -sfv /$directory/ports/hex-a-hop/conf/.hex-a-hop ~/

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "hex-a-hop"  -c "./hex-a-hop.gptk" &
LD_LIBRARY_PATH="$PWD/libs" SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./hex-a-hop -n 2>&1 | tee -a ./log.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0