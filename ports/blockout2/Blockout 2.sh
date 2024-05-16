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
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR=/$directory/ports/blockout2/
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

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

cd $GAMEDIR

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

export BL2_HOME=/$directory/ports/blockout2
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO rm -rf ~/.bl2
ln -sfv /$directory/ports/blockout2/conf/.bl2 ~/

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "blockout" -c "./blockout2.gptk" &
./blockout
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1
