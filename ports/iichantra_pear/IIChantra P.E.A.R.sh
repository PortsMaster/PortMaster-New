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

GAMEDIR=/$directory/ports/iichantra_pear
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

export SDL12COMPAT_USE_GAME_CONTROLLERS=1
export LD_LIBRARY_PATH="$PWD/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO sed -i "s|window_width = [0-9]\+;|window_width = $DISPLAY_WIDTH;|g" $GAMEDIR/config/default.lua
$ESUDO sed -i "s|window_height = [0-9]\+;|window_height = $DISPLAY_HEIGHT;|g" $GAMEDIR/config/default.lua

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "iiChantra.Release" -c "./iiChantra.gptk" &
./iiChantra.Release


$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0

