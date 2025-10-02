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

GAMEDIR=/$directory/ports/netsurf
CONFDIR="$GAMEDIR/conf/"
BINARY=nsfb

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

mkdir -p "$GAMEDIR/conf"

if [ "$CFW_NAME" = "TrimUI" ]; then
    export LD_LIBRARY_PATH="$GAMEDIR/libs.compat:$LD_LIBRARY_PATH"
    export BINARY=nsfb.compat
elif [[ $CFW_NAME == "ArkOS"* ]]; then
    export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
	export BINARY=nsfb.compat
elif [ "$CFW_NAME" = "ROCKNIX" ]; then
    rm -f "$GAMEDIR/libs.${DEVICE_ARCH}/libwayland-client.so.0"
    export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
else
    export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
fi

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export NETSURFRES="$GAMEDIR/resources"
export NETSURF_DIR="$GAMEDIR/"
export XDG_DATA_HOME="$CONFDIR"

cd $GAMEDIR

$GPTOKEYB "$BINARY" -c "./netsurf.gptk" &
echo $DISPLAY_WIDTH
./$BINARY -fsdl -w"$DISPLAY_WIDTH" -h"$DISPLAY_HEIGHT" https://wiby.me

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0