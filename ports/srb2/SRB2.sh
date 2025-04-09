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

GAMEDIR=/$directory/ports/SRB2/

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd /$directory/ports/SRB2/

if [ $LOWRES=="Y" ]; then
  swidth="480"
  sheight="320"
else
  swidth="640"
  sheight="480"
fi

export LD_LIBRARY_PATH="$PWD/libs:$LD_LIBRARY_PATH"
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "lsdlsrb2" -c "./srb2.$ANALOG_STICKS.gptk" &
./lsdlsrb2 -nojoy -home ./conf -width $swidth -height $sheight

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1
