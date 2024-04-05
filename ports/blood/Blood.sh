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

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/storage/roms/ports/Blood/lib:/usr/lib"
GAMEDIR="/$directory/ports/Blood"

GPTOKEYB_CONFIG="$GAMEDIR/nblood.gptk"

$ESUDO rm -rf ~/.config/nblood
$ESUDO ln -s $GAMEDIR/conf/nblood ~/.config/
cd $GAMEDIR

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "nblood" -c $GPTOKEYB_CONFIG &
./nblood 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
unset LD_LIBRARY_PATH
printf "\033c" >> /dev/tty1

