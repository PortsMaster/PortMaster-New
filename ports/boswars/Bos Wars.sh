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
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR=/$directory/ports/boswars
CONFDIR="$GAMEDIR/conf/"
BINARY=boswars

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

mkdir -p "$GAMEDIR/conf"

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export XDG_DATA_HOME="$CONFDIR"

bind_directories ~/.boswars $GAMEDIR/conf/.boswars

sed -i "s/\(VideoWidth = \)[0-9]\+\(,\)/\1$DISPLAY_WIDTH\2/" $GAMEDIR/conf/.boswars/preferences.lua
sed -i "s/\(VideoHeight = \)[0-9]\+\(,\)/\1$DISPLAY_HEIGHT\2/" $GAMEDIR/conf/.boswars/preferences.lua

cd $GAMEDIR

$GPTOKEYB "$BINARY" -c ./boswars.${ANALOG_STICKS}.gptk textinput &
./$BINARY -d packagedata

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
