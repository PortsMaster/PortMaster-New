#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt

get_controls

GAMEDIR="/$directory/ports/devilution"
cd $GAMEDIR

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/lib32:$GAMEDIR/libs"
$GPTOKEYB "devilutionx" &
./devilutionx --config-dir $GAMEDIR --data-dir $GAMEDIR --save-dir $GAMEDIR 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof gptokeyb)
unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1
