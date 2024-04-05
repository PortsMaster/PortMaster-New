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

GAMEDIR=/$directory/ports/nanobounce

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR


# Make sure uinput is accessible so we can make use of the gptokeyb controls.  351Elec/AmberElec, uOS and JelOS always runs in root, naughty naughty.  
# The other distros don't so the $ESUDO variable provides the sudo or not dependant on the OS this script is run from.
$ESUDO chmod 666 /dev/uinput

#for old portmaster installs where DEVICE_ARCH may not be defined or empty take the (previous) default
DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$GPTOKEYB "bounce.${DEVICE_ARCH}" -c "./bounce.gptk" &
./bounce.${DEVICE_ARCH}
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0



