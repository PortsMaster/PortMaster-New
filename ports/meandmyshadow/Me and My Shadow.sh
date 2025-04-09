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
get_controls

## TODO: Change to PortMaster/tty when Johnnyonflame merges the changes in,
CUR_TTY=/dev/tty0

PORTDIR="/$directory/ports"
GAMEDIR="$PORTDIR/meandmyshadow"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

$ESUDO chmod 666 $CUR_TTY
export TERM=linux
printf "\033c" >$CUR_TTY

## RUN SCRIPT HERE

echo "Starting game." >$CUR_TTY

export PORTMASTER_HOME="$GAMEDIR"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

$GPTOKEYB "meandmyshadow" -c meandmyshadow.gptk &
./meandmyshadow

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &

# Disable console
printf "\033c" >$CUR_TTY