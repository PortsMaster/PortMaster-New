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

export PORT_32BIT="N"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR="/$directory/ports/devilutionx"
cd $GAMEDIR

DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"

$GPTOKEYB "devil.${DEVICE_ARCH}" -c "$GAMEDIR/devilutionx.gptk" &

if command -v pm_platform_helper >/dev/null 2>&1; then
  pm_platform_helper "$GAMEDIR/devil.${DEVICE_ARCH}"
fi

./devil.${DEVICE_ARCH} --config-dir $GAMEDIR --data-dir $GAMEDIR --save-dir $GAMEDIR 2>&1 | tee $GAMEDIR/log.txt

if command -v pm_finish >/dev/null 2>&1; then
  pm_finish
else
  $ESUDO kill -9 $(pidof gptokeyb) 2>/dev/null || true
  $ESUDO systemctl restart oga_events &
  printf "\033c" >> /dev/tty1
fi
