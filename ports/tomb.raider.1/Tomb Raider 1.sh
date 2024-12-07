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

