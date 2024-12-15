#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt

get_controls

GAMEDIR=/$directory/ports/shippy

exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO rm -rf /storage/.local/share/shippy
ln -sfv /$directory/ports/shippy /storage/.local/share/shippy


cd $GAMEDIR

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "shippy" -c shippy.gptk &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./shippy

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
