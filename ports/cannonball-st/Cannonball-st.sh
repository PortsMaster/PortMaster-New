#!/bin/bash
if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source "$controlfolder/control.txt"

get_controls

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
printf "\033c" > /dev/tty0
printf "\033c" > /dev/tty1

GAMEDIR="/$directory/ports/Cannonball-st"

export LD_LIBRARY_PATH="/$directory/ports/Cannonball-st/lib"
 
cd "$GAMEDIR"

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "cannonball" &
echo "Loading, please wait... " > /dev/tty0

$ESUDO chmod +x "$GAMEDIR/cannonball"

./cannonball |& tee log.txt /dev/tty0

$ESUDO kill -9 "$(pidof gptokeyb)"
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1
printf "\033c" > /dev/tty0
