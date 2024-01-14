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

GAMEDIR=/$directory/ports/DomeRomantik/
cd $GAMEDIR

if [[ "$(cat /sys/firmware/devicetree/base/model | tr -d '\0')" == "Anbernic RG552" ]]; then

  mv domeromantik-linuxRG552.zip domeromantik-linux.zip
  mv domeromantik-linuxRG552.gptk domeromantik-linux.gptk 

else

  rm domeromantik-linuxRG552.zip domeromantik-linuxRG552.gptk 

fi

export FRT_NO_EXIT_SHORTCUTS=FRT_NO_EXIT_SHORTCUTS

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "frt_3.5.2" -c "./domeromantik-linux.gptk" &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./frt_3.5.2 --main-pack domeromantik-linux.zip
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0

