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

$ESUDO chmod 666 /dev/tty1

GAMEDIR="/$directory/ports/rott"

ROTTBIN="rott_sw"
if [ -f "$GAMEDIR/DARKWAR.WAD" ]; then
  ROTTBIN="rott"
fi

cd $GAMEDIR

$ESUDO fallocate -l 500M /swapfile
$ESUDO chmod 600 /swapfile
$ESUDO mkswap /swapfile
$ESUDO swapon /swapfile

$ESUDO rm -rf ~/.rott
$ESUDO ln -sfv $GAMEDIR/conf/.rott ~/

$ESUDO $controlfolder/oga_controls $ROTTBIN $param_device &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./$ROTTBIN 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof oga_controls)
$ESUDO systemctl restart oga_events &

$ESUDO swapoff -v /swapfile
$ESUDO rm -f /swapfile
printf "\033c" >> /dev/tty1


