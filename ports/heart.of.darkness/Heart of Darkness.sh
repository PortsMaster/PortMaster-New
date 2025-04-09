#!/bin/bash

PORTNAME="Oddworld: Abe's Oddysee"

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

GAMEDIR=/$directory/ports/hode
cd $GAMEDIR

$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "hode" -c $GAMEDIR/hode.gptk &

if [[ -e "/usr/share/plymouth/themes/text.plymouth" ]]; then
	SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 ./hode 2>&1 | tee ./log.txt
else
	SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./hode 2>&1 | tee ./log.txt
fi
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty1


