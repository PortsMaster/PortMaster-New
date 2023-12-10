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

GAMEDIR="/$directory/ports/rocksndiamonds"

$ESUDO chmod 666 /dev/tty1

$ESUDO rm -rf ~/.rocksndiamonds
ln -sfv $GAMEDIR/conf/.rocksndiamonds/ ~/
cd $GAMEDIR
$ESUDO $controlfolder/oga_controls rocksndiamonds $param_device &
./rocksndiamonds 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof oga_controls)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1
