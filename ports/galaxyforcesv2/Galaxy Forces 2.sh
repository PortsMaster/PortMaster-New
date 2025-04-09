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

GAMEDIR=/$directory/ports/galaxyforcesv2

exec > >(tee "$GAMEDIR/log.txt") 2>&1

#export XDG_DATA_HOME="$GAMEDATA"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUT="PortMaster"


cd $GAMEDIR

$ESUDO chmod 666 /dev/uinput

#Check to start in single player or server mode.
./imgui-demo -p 0 -t "Galaxy Forces v2"

gtype=$?

if [ $gtype == 0 ]; then
  $GPTOKEYB "galaxyv2" textinput -c galaxyforcesv2.gptk &
  ./galaxyv2
elif [ $gtype == 120 ]; then
  # Used to read ip address linked to exit code. Each line is also a variable.
  source Assets/config.txt
  sed -i "s/.*SERVER.*/*SERVER \"$server1_ip\"/" last_connect.txt
  $GPTOKEYB "galaxyv2" textinput -c galaxyforcesv2.gptk &
 ./galaxyv2
fi

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
