#!/bin/bash
if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/device_info.txt

get_controls

GAMEDIR=/$directory/ports/billyfrontier
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_VIDEO_GL_DRIVER="$GAMEDIR/libs.${DEVICE_ARCH}/libGL.so.1"

cd $GAMEDIR

if [ "$ANALOG_STICKS" = "0" ]; then
  sed -i 's/up = up/up = mouse_movement_up/' billyfrontier.gptk
  sed -i 's/down = down/down = mouse_movement_down/' billyfrontier.gptk
  sed -i 's/left = left/left = mouse_movement_left/' billyfrontier.gptk
  sed -i 's/right = right/right = mouse_movement_right/' billyfrontier.gptk
fi

$GPTOKEYB "BillyFrontier.${DEVICE_ARCH}" -c "./billyfrontier.gptk" &
./BillyFrontier.${DEVICE_ARCH}

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0