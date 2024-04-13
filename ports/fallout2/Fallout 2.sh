#!/bin/bash
# Ported by Maciej Suminski <orson at orson dot net dot pl>
# Built from https://github.com/alexbatalov/fallout2-ce

PORTNAME="Fallout 2"

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

cd /$directory/ports/fallout2

for f in data critter.dat master.dat patch000.dat; do
	if [[ ! -e "$f" ]]; then
		echo Missing file: $f > /dev/tty0
		sleep 5
		printf "\033c" >> /dev/tty0
		exit 1
	fi
done

$ESUDO chmod 666 /dev/uinput
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
$GPTOKEYB "fallout2-ce" -c "./fallout2.gptk.$ANALOGSTICKS" -hotkey back &
if [[ $whichos == *"ArkOS"* ]]; then
  LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 ./fallout2-ce 2>&1 | tee -a ./log.txt
else
  ./fallout2-ce 2>&1 | tee -a ./log.txt
fi

$ESUDO kill -9 $(pidof gptokeyb)
unset SDL_GAMECONTROLLERCONFIG
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty0

