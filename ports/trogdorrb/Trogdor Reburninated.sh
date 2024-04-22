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

#export PORT_32BIT="Y" # If using a 32 bit port
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR=/$directory/ports/trogdorrb/

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# if XDG Path does not work
#$ESUDO rm -rf ~/.portfolder
#ln -sfv $GAMEDIR/conf/.portfolder ~/

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
#export TEXTINPUTINTERACTIVE="Y"

# If using gl4es
#if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
#  source "${controlfolder}/libgl_${CFW_NAME}.txt"
#else
#  source "${controlfolder}/libgl_default.txt"
#fi

# Only for xbox360 mode
#$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "tdrb.${DEVICE_ARCH}" -c "./tdrb.gptk" &
./tdrb.${DEVICE_ARCH}

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty0