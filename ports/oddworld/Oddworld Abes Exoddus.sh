#!/bin/bash
# Ported by Maciej Suminski <orson at orson dot net dot pl>
# Built from https://github.com/AliveTeam/alive_reversing

PORTNAME="Oddworld: Abe's Exoddus"

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

GAMEDIR="/$directory/ports/relive"
cd "$GAMEDIR/exoddus"

$ESUDO chmod 666 /dev/uinput
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
$GPTOKEYB "relive" &

export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
if [[ $whichos == *"ArkOS"* ]]; then
  LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 ../relive 2>&1 | tee -a ../log.txt
else
  ../relive 2>&1 | tee -a ../log.txt
fi

$ESUDO kill -9 $(pidof gptokeyb)
unset SDL_GAMECONTROLLERCONFIG
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1

