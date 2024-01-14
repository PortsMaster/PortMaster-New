#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "/roms/ports" ]; then
  controlfolder="/roms/ports/PortMaster"
else
  controlfolder="/storage/roms/ports/PortMaster"
fi

source $controlfolder/control.txt

get_controls

GAMEDIR="/$directory/ports/bluesbrothers/"
cd $GAMEDIR

$ESUDO chmod 666 /dev/tty1
$GPTOKEYB "blues" &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" LD_LIBRARY_PATH="$GAMEDIR/libs":LD_LIBRARY_PATH ./blues --fullscreen --filter=nearest --datapath="$GAMEDIR/gamedata" 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof oga_controls)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty1
