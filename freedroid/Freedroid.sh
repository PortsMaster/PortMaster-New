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

GAMEDIR=/$directory/ports/freedroid
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

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "freedroidRPG" -c "./freedroid.gptk" &
LD_LIBRARY_PATH="$PWD/libs" SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./freedroidRPG -n 2>&1 | tee -a ./log.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0