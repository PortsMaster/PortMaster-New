#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then 
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster" 
fi

source $controlfolder/control.txt
source $controlfolder/device_info.txt
export PORT_32BIT="Y"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR=/$directory/ports/bunnysflowers/
cd $GAMEDIR
DROID="game.droid"

exec > >(tee "$GAMEDIR/log.txt") 2>&1

# check if we have new enough version of PortMaster that contains xdelta3
if [ ! -f "$controlfolder/xdelta3" ]; then
  echo "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info." > /dev/tty0
  sleep 5
  exit 1
fi

# patch is based on steam app/depot/build/manifest 1375480 1375482 6478677 7594562866968444214 to enable autosave
if [ -f "./gamedata/data.win" ] && md5sum -c hash.md5 >/dev/null 2>&1; then
  ${controlfolder}/xdelta3 -d -s "$GAMEDIR/gamedata/data.win" "$GAMEDIR/bunnysflowers.patch" "$GAMEDIR/gamedata/$DROID" && \
  rm "$GAMEDIR/gamedata/data.win"
fi

$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "gmloader" &

export LD_LIBRARY_PATH="/usr/lib:/usr/lib32:$GAMEDIR/lib"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"

$ESUDO chmod +x "$GAMEDIR/gmloader"
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./gmloader bunnysflowers.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0