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

GAMEDIR=/$directory/ports/flare
cd $GAMEDIR

CONFDIR="$GAMEDIR/flare"
mkdir -p "$CONFDIR"
export XDG_DATA_HOME="$CONFDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"

$ESUDO rm -rf ~/.config/flare
ln -sfv /$directory/ports/flare/conf/.config/flare ~/.config/

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "flare.$DEVICE_ARCH" xbox360 &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./flare.$DEVICE_ARCH
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
