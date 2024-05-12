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

GAMEDIR=/$directory/ports/freedroid

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

$ESUDO rm -rf ~/.freedroid_rpg
ln -sfv /$directory/ports/freedroid/conf/.freedroid_rpg ~/


if [[ $LOWRES == "Y" ]]; then
  if [[ -e $GAMEDIR/conf/fdrpg.cfg.lowres ]]; then
    mv -f -v $GAMEDIR/conf/fdrpg.cfg.lowres $GAMEDIR/conf/.freedroid_rpg/fdrpg.cfg    
    fi
elif [[ "$(cat /sys/firmware/devicetree/base/model)" == "Anbernic RG552" ]] || [[ -e "/dev/input/by-path/platform-singleadc-joypad-event-joystick" ]]; then
  if [[ -e $GAMEDIR/conf/fdrpg.cfg.552 ]]; then
    mv -f -v $GAMEDIR/conf/fdrpg.cfg.552 $GAMEDIR/conf/.freedroid_rpg/fdrpg.cfg
  fi	
else
  if [[ -e $GAMEDIR/conf/fdrpg.cfg.640 ]]; then
    mv -f -v $GAMEDIR/conf/fdrpg.cfg.640 $GAMEDIR/conf/.freedroid_rpg/fdrpg.cfg
  fi
fi

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "freedroidRPG" -c "./freedroid.gptk" &
./freedroidRPG
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
