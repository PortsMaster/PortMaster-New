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

GAMEDIR="/$directory/ports/sorr"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [ -f $GAMEDIR/savegame/savegame-widescreen.sor ]; then
  if [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
    rm -f $GAMEDIR/savegame/savegame.sor
    mv -f $GAMEDIR/savegame/savegame-widescreen.sor $GAMEDIR/savegame/savegame.sor
  fi
fi

export LD_LIBRARY_PATH="$GAMEDIR/libs:/usr/lib32:/usr/local/lib/arm-linux-gnueabihf:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO chmod 777 -R $GAMEDIR/*

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "bgdi" -c "$GAMEDIR/sorr.gptk" &
./bgdi $(find "$GAMEDIR" -type f -iname "sorr.dat")

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty0
