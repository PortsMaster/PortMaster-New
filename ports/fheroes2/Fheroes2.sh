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
source $controlfolder/device_info.txt

get_controls

GAMEDIR=/$directory/ports/fheroes2


$ESUDO rm -rf ~/.config/fheroes2
ln -sfv ${GAMEDIR}/conf/fheroes2/ ~/.config/
$ESUDO rm -rf ~/.local/share/fheroes2
ln -sfv ${GAMEDIR}/save/fheroes2/ ~/.local/share/

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO chmod 666 /dev/uinput
cd $GAMEDIR/

$GPTOKEYB "fheroes2" -c "./fheroes2.gptk" &
./fheroes2 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty0
