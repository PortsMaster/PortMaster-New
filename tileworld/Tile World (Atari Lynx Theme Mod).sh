#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt

get_controls

GAMEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/tileworld"

$ESUDO chmod ugo+rwx -R $GAMEDIR/*
$ESUDO chmod ugo+rwx $GAMEDIR/../*.sh

cd $GAMEDIR

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

# system
export TERM=linux
export XDG_RUNTIME_DIR=/run/user/$UID/
export LD_LIBRARY_PATH=$GAMEDIR/libs

$ESUDO rm $GAMEDIR/log.txt
sleep 1

# set game mod
cp -f -v $GAMEDIR/res/rc.hh.original $GAMEDIR/res/rc
cp -f -v $GAMEDIR/res/atiles_lynx.png $GAMEDIR/res/atiles.png

$GPTOKEYB "tworld-hh" -c "$GAMEDIR/tileworld.gptk" &
./tworld-hh -F 2>&1 | tee -a $GAMEDIR/log.txt

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
unset SDL_GAMECONTROLLERCONFIG
unset LD_LIBRARY_PATH
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty0
