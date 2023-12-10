#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "/roms/ports" ]; then
  controlfolder="/roms/ports/PortMaster"
 elif [ -d "/roms2/ports" ]; then
  controlfolder="/roms2/ports/PortMaster"
else
  controlfolder="/storage/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/tasksetter

get_controls

GAMEDIR="/$directory/ports/tombraider1"

cd $GAMEDIR

$ESUDO chmod 666 /dev/tty1

$ESUDO ./oga_controls OpenLara $param_device &
$ESUDO rm -rf ~/.openlara
ln -sfv $GAMEDIR/conf/.openlara/ ~/

$ESUDO $controlfolder/oga_controls OpenLara $param_device &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./OpenLara 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof oga_controls)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1
