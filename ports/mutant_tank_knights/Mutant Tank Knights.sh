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

GAMEDIR=/$directory/ports/mutant_tank_knights

# Ensure the conf directory exists
mkdir -p "$GAMEDIR/conf"

exec > >(tee "$GAMEDIR/log.txt") 2>&1

export XDG_CONFIG_HOME="$CONFDIR"
export XDG_DATA_HOME="$GAMEDATA"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

cd $GAMEDIR

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "mtanks" -c mutant_tank_knights.gptk &
./mtanks

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
