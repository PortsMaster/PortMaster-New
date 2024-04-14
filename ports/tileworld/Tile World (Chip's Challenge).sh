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

GAMEDIR="/$directory/ports/tileworld"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

[ ! -f "$GAMEDIR/port_cfg" ] && cp -f "$GAMEDIR/port_cfg.template" "$GAMEDIR/port_cfg"

$ESUDO chmod 777 -R $GAMEDIR/*

cd $GAMEDIR

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1

# system
export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO rm -rf ~/.tworld
$ESUDO ln -s $GAMEDIR/conf/.tworld ~/

# set game mod
cp -f -v $GAMEDIR/res/rc.hh.original $GAMEDIR/res/rc
cp -f -v $GAMEDIR/res/atiles_orig.png $GAMEDIR/res/atiles.png

$GPTOKEYB "tworld-hh.${DEVICE_ARCH}" -c "$GAMEDIR/tileworld.gptk" &
./tworld-hh.${DEVICE_ARCH} -F

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty0
