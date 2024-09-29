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

GAMEDIR=/$directory/ports/drilbertiidiggeredoo

export XDG_DATA_HOME="$GAMEDIR/saves" # allowing saving to the same path as the game
export XDG_CONFIG_HOME="$GAMEDIR/saves"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"

cd $GAMEDIR

"$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# patch game
if [ -e "patch/patched_true" ]; then
  echo "already patched"
else
  cp patch/gfx/*.png gamedata/gfx/
  ./bin/patch.${DEVICE_ARCH} gamedata/main.lua < patch/main.lua.diff
  ./bin/patch.${DEVICE_ARCH} gamedata/render.lua < patch/render.lua.diff
  touch patch/patched_true
  echo "patching complete"
fi

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "love.${DEVICE_ARCH}" -c "./drilbertiidiggeredoo.gptk" &
./bin/love.${DEVICE_ARCH} gamedata

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0


