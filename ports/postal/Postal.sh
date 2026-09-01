#!/bin/bash
# Postal (1997)
# Porter: initdream

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

BINARYNAME="postal1"
GAMEDIR=/$directory/ports/postal
CONFDIR="$GAMEDIR/conf/"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

mkdir -p "$GAMEDIR/conf"

export XDG_DATA_HOME="$CONFDIR"

if [[ "$CFW_NAME" = "ROCKNIX" ]]; then
  audio_backend=alsa
fi

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTINTERACTIVE="Y"

if [ -f "$GAMEDIR/POSTAL.INI" ]; then
  sed -i 's/^UseNewMouse = 1/UseNewMouse = 0/' "$GAMEDIR/POSTAL.INI"
  sed -i 's/^UseMouse = 1/UseMouse = 0/' "$GAMEDIR/POSTAL.INI"
fi

$GPTOKEYB "${BINARYNAME}.${DEVICE_ARCH}" xbox360 &
pm_platform_helper "$GAMEDIR/${BINARYNAME}.${DEVICE_ARCH}"
./${BINARYNAME}.${DEVICE_ARCH}

pm_finish
