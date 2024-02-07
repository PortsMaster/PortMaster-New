#!/bin/bash
# PORTMASTER: jetsetwilly.zip, Jet Set Willy.sh

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt

get_controls

GAMEDIR=/$directory/ports/jetsetwilly

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "jetsetwilly" -c jetsetwilly.gptk &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./jetsetwilly

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0