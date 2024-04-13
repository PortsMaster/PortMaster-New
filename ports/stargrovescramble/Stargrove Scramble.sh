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

$ESUDO chmod 666 /dev/tty0

GAMEDIR=/$directory/ports/stargrovescramble

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

if [ -f "./gamedata/data.win" ]; then
  mv gamedata/data.win gamedata/game.droid
  mkdir -p gamedata/assets
  cd gamedata
  mv *.ogg assets/
  zip -r -0 ../stargrovescramble.apk assets
  rm -Rf assets
fi

cd $GAMEDIR

$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "gmloader" -c ./stargrovescramble.gptk &

$ESUDO chmod +x "$GAMEDIR/gmloader"

./gmloader stargrovescramble.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0

