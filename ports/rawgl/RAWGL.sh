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

# the included copy of oga_controls seems to breaks exiting on non oga devices...
rm -f "/$directory/ports/rawgl/oga_controls"

get_controls

GAMEDIR="/$directory/ports/rawgl"
cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO chmod 666 /dev/tty1

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

if [[ $LOWRES == "Y" ]]; then
  rawgl_screen="--window=480x320"
elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
  rawgl_screen="--window=854x480"
else
  rawgl_screen="--window=640x480"
fi

# add support for 3DO iso file
GAMEDATA="$(ls $GAMEDIR/gamedata/*.iso | head -1)"
if [[ "$GAMEDATA" == "" ]]; then
  GAMEDATA="$GAMEDIR/gamedata"
fi

$GPTOKEYB "rawgl" & 
./rawgl $rawgl_screen --render=software --datapath="$GAMEDATA" --language=us

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1