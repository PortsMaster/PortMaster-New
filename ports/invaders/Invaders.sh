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

GAMEDIR="/$directory/ports/Invaders"
cd $GAMEDIR

if [[ "$LOWRES" == "Y" ]]; then
  AppToLaunch="si78c_lowres"
elif [[ "$(cat /sys/firmware/devicetree/base/model)" == "Anbernic RG552" ]] && [[ -e "/dev/input/by-path/platform-singleadc-joypad-event-joystick" ]]; then
  AppToLaunch="si78c_hires"
else
  AppToLaunch="si78c"
fi

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "$AppToLaunch" -c "Invaders.gptk" &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./bin/$AppToLaunch 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1
printf "\033c" >> /dev/tty0
