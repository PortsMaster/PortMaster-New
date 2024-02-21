#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
if [ -z ${TASKSET+x} ]; then
  source $controlfolder/tasksetter
fi

get_controls

## TODO: Change to PortMaster/tty when Johnnyonflame merges the changes in,
CUR_TTY=/dev/tty0

PORTDIR="/$directory/ports"
GAMEDIR="$PORTDIR/yatka"

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

## RUN SCRIPT HERE

echo "Starting game." > $CUR_TTY

$GPTOKEYB "yatka" -c yatka.gptk &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" LD_LIBRARY_PATH="$PWD/libs" $TASKSET ./yatka --scale2x

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &

# Disable console
printf "\033c" > $CUR_TTY
