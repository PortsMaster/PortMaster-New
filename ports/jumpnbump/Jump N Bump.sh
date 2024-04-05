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

GAMEDIR=/$directory/ports/jumpnbump

exec > >(tee "$GAMEDIR/log.txt") 2>&1

export XDG_DATA_HOME="$GAMEDATA"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs"
export TEXTINPUTINTERACTIVE="Y"

cd $GAMEDIR

#Check to start in single player or server mode.
./text_viewer -f 24 -w -y -t "Press A for Yes for Single player, No for server" --input_file instructions.txt
gtype=$?

$ESUDO chmod 666 /dev/uinput


if [ $gtype == 21 ]; then
  $GPTOKEYB "jumpnbump" -c jumpnbump.gptk &
  ./jumpnbump -scaleup
elif [ $gtype == 0 ]; then
  ./text_viewer -f 24 -w -y -t "Press A for Yes for Server, No for Client Connection" --input_file instructions2.txt
  cstype=$?
  if [ $cstype == 21 ]; then
    $GPTOKEYB "jumpnbump" -c jumpnbump.gptk &
    ./jumpnbump -scaleup -server 1
  elif [ $cstype == 0 ]; then
    $GPTOKEYB "enter_text" -c input.gptk &
    ./enter_text
    $ESUDO kill -9 $(pidof gptokeyb)
    cip_add=$(cat "ip.txt")
    $GPTOKEYB "jumpnbump" -c jumpnbump.gptk &
    ./jumpnbump -connect $cip_add -scaleup
  fi
fi
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
