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

export PORT_32BIT="Y"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR="/$directory/ports/chipndale"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd "$GAMEDIR"

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export LD_LIBRARY_PATH="/usr/lib:/usr/lib32:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

[ -f "$GAMEDIR/gamedata/data.win" ] && mv $GAMEDIR/gamedata/data.win $GAMEDIR/gamedata/game.droid
[ -f "$GAMEDIR/gamedata/game.win" ] && mv $GAMEDIR/gamedata/game.win $GAMEDIR/gamedata/game.droid

$ESUDO chmod 777 -R $GAMEDIR/*

printf "\033c" > /dev/tty0
printf "\033c" > /dev/tty1
echo "Loading, please wait... " > /dev/tty0

$GPTOKEYB "gmloader" -c "$GAMEDIR/chip.gptk" &
./gmloader chip.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty0
