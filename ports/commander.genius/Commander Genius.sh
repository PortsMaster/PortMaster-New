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

GAMEDIR="/$directory/ports/cgenius"

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

$ESUDO rm -rf ~/.CommanderGenius

ln -sfv $GAMEDIR/.CommanderGenius/ ~/
cd $GAMEDIR
$GPTOKEYB "CGeniusExe" -c "./cgenius.gptk" &

./CGeniusExe 2>&1 | tee $GAMEDIR/log.txt

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1

