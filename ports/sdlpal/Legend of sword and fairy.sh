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
source $controlfolder/device_info.txt

get_controls

GAMEDIR=/$directory/ports/sdlpal
cd $GAMEDIR

if [[ "$DEVICE_ARCH" == "aarch64" ]]; then
  suffix="arm64"
elif [[ "$DEVICE_ARCH" == "armhf" ]]; then
  suffix="armhf"
elif [[ "$DEVICE_ARCH" == "x86_64" ]]; then
  suffix="64"
else
  exit 1
fi

exec="sdlpal.${suffix}"

#$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "$exec" -c "./sdlpal.gptk" &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./$exec 2>&1

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty0

