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

GAMEDIR="/$directory/ports/spacecadetpinball"

$ESUDO rm -rf ~/.local/share/SpaceCadetPinball
ln -sfv $GAMEDIR/conf/SpaceCadetPinball ~/.local/share/

cd $GAMEDIR
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "SpaceCadetPinball" &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./SpaceCadetPinball -fullscreen 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty1