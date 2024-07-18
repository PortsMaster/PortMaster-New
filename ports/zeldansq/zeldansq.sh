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

## TODO: Change to PortMaster/tty when Johnnyonflame merges the changes in,
CUR_TTY=/dev/tty0

PORTDIR="/$directory/ports"
GAMEDIR="$PORTDIR/zeldansq"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [ "$VERSION" == "19.10 (Eoan Ermine)" ]; then

cp /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 /$GAMEDIR/libs && mv /$GAMEDIR/libs/libSDL2-2.0.so.0.10.0 /$GAMEDIR/libs/libSDL2-2.0.so.0

fi

cd $GAMEDIR

$ESUDO chmod 666 $CUR_TTY

export TERM=linux
printf "\033c" > $CUR_TTY

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

## RUN SCRIPT HERE
$ESUDO chmod -x ./zeldansq

echo "Starting game." > $CUR_TTY

$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "zeldansq" -c "zeldansq.gptk" &
./zeldansq

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty0