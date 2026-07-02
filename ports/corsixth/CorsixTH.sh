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

GAMEDIR="/$directory/ports/CorsixTH"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

if   [[ $ANALOG_STICKS == '1' ]]; then
  GPTOKEYB_CONFIG="$GAMEDIR/corsixth.gptk.leftanalog"
else
  GPTOKEYB_CONFIG="$GAMEDIR/corsixth.gptk.rightanalog"
fi

export TEXTINPUTINTERACTIVE="Y"
export TEXTINPUTNOAUTOCAPITALS="Y"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

cd $GAMEDIR

[ ! -e "./lpeg.so" ] && cp $GAMEDIR/libs.${DEVICE_ARCH}/lpeg.so .
[ ! -e "./lfs.so" ] && cp $GAMEDIR/libs.${DEVICE_ARCH}/lfs.so .

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "corsix-th.${DEVICE_ARCH}" $HOTKEY textinput -c "$GPTOKEYB_CONFIG" &
./corsix-th.${DEVICE_ARCH} --interpreter="$GAMEDIR/CorsixTH.lua"

pm_finish
