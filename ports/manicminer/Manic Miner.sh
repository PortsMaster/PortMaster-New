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

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR=/$directory/ports/manicminer

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "manicminer.${DEVICE_ARCH}" -c "./manicminer.gptk" &

SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./manicminer.${DEVICE_ARCH}


$ESUDO kill -9 $(pidof gptokeyb)
if [ $DEVICE_ARCH != "x86_64" ]; then
  $ESUDO systemctl restart oga_events &
  printf "\033c" > /dev/tty0
fi
