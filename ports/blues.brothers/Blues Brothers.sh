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

GAMEDIR="/$directory/ports/bluesbrothers/"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

$ESUDO chmod 666 /dev/tty1

$GPTOKEYB "blues" &
./blues --fullscreen --filter=nearest --datapath="$GAMEDIR/gamedata"

$ESUDO kill -9 $(pidof oga_controls)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty1

