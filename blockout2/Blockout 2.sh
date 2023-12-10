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

if [[ $LOWRES == "Y" ]]; then
  if [ ! -f "/$directory/ports/blockout2/conf/.bl2/setup.dat" ]; then
    cp -f /$directory/ports/blockout2/conf/res_configs/setup.dat.640 /$directory/ports/blockout2/conf/.bl2/setup.dat
  fi
elif [ "$(cat /sys/firmware/devicetree/base/model)" == "Anbernic RG552" ]; then
  if [ ! -f "/$directory/ports/blockout2/conf/.bl2/setup.dat" ]; then
    cp -f /$directory/ports/blockout2/conf/res_configs/setup.dat.552 /$directory/ports/blockout2/conf/.bl2/setup.dat
  fi
else
  if [ ! -f "/$directory/ports/blockout2/conf/.bl2/setup.dat" ]; then
    cp -f /$directory/ports/blockout2/conf/res_configs/setup.dat.640 /$directory/ports/blockout2/conf/.bl2/setup.dat
  fi
fi

export LIBGL_ES=2
export LIBGL_GL=21
export LIBGL_FB=4
export BL2_HOME=/$directory/ports/blockout2

cd /$directory/ports/blockout2

$ESUDO rm -rf ~/.bl2
ln -sfv /$directory/ports/blockout2/conf/.bl2 ~/


$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "blockout" -c "./blockout2.gptk" &
LD_LIBRARY_PATH="$PWD/libs" SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./blockout 2>&1 | tee -a ./log.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1