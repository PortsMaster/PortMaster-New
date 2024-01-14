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

GAMEDIR=/$directory/ports/PlaqueAttackRemake/
cd $GAMEDIR

resolution=$(xrandr | grep -oP '\d{3,4}x\d{3,4}')
width=$(echo $resolution | cut -d'x' -f1)
height=$(echo $resolution | cut -d'x' -f2)

aspect_ratio=$(awk "BEGIN {print $width/$height}")
target_ratio=$(awk "BEGIN {print 4/3}")

if (( $(echo "$aspect_ratio != $target_ratio" | bc -l) )); then
  rm PlaqueAttackRemake4-3.zip
  mv PlaqueAttackRemake16-9.zip PlaqueAttackRemake.zip
else
  rm PlaqueAttackRemake16-9.zip
  mv PlaqueAttackRemake4-3.zip PlaqueAttackRemake.zip
fi

export FRT_NO_EXIT_SHORTCUTS=FRT_NO_EXIT_SHORTCUTS

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "frt_3.5.2" -c "./plaque.gptk" textinput &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./frt_3.5.2 --main-pack PlaqueAttackRemake.zip
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
