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

GAMEDIR=/$directory/ports/oquonie/

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

cd $GAMEDIR
$GPTOKEYB "uxnemu" -c "$GAMEDIR/oquonie.gptk" &
./uxnemu -f oquonie.rom

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
unset SDL_GAMECONTROLLERCONFIG
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty0


