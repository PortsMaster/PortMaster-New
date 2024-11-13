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

[ -f "/etc/os-release" ] && source "/etc/os-release"

GAMEDIR=/$directory/ports/thestarlitescape
exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [ "$OS_NAME" == "JELOS" ]; then
  export SPA_PLUGIN_DIR="/usr/lib32/spa-0.2"
  export PIPEWIRE_MODULE_DIR="/usr/lib32/pipewire-0.3/"
fi

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$GAMEDIR/utils/libs"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"

cd $GAMEDIR

[ -f "./gamedata/data.win" ] && mv gamedata/data.win gamedata/game.droid
[ -f "./gamedata/game.win" ] && mv gamedata/game.win gamedata/game.droid

$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "gmloader" -c ./thestarlitescape.gptk &

$ESUDO chmod +x "$GAMEDIR/gmloader"

./gmloader thestarlitescape.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
