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

GAMEDIR="/$directory/ports/jukeboxadventure"

$ESUDO chmod 666 /dev/tty1

cd $GAMEDIR
$GPTOKEYB "bbja" &
LD_LIBRARY_PATH="$GAMEDIR/lib:$LD_LIBRARY_PATH" SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./bbja --fullscreen --filter=nearest --datapath="$GAMEDIR/gamedata" 2>&1 | tee $GAMEDIR/log.txt
printf "\033c" >> /dev/tty1

