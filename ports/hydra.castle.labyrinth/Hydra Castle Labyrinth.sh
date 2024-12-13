#!/bin/bash
# PORTMASTER: hydra.castle.labyrinth.zip, Hydra Castle Labyrinth.sh

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
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

$ESUDO chmod 666 /dev/tty1

GAMEDIR="/$directory/ports/hcl"

bind_directories ~/.hydracastlelabyrinth $GAMEDIR/conf/.hydracastlelabyrinth

cd $GAMEDIR
$ESUDO $controlfolder/oga_controls hcl $param_device &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./hcl 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof oga_controls)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1


