#!/bin/bash
if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source "$controlfolder/control.txt"
source $controlfolder/device_info.txt

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
printf "\033c" > /dev/tty0
printf "\033c" > /dev/tty1

GAMEDIR="/$directory/ports/Hydorah"

 
cd "$GAMEDIR"

export GMLOADER_PLATFORM="os_windows" \
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"

export LD_LIBRARY_PATH="/usr/lib:/usr/lib32:/$directory/ports/Hydorah/lib"


if [ ! -f flagfile ]; then
  $SUDO $controlfolder/xdelta3 -d -s gamedata/data.win gamedata/HYDORAH_STEAM.xdelta gamedata/game.droid
  touch flagfile
fi

rm -r gamedata/data.win

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "gmloader" &
echo "Loading, please wait... " > /dev/tty0
$ESUDO chmod +x "$GAMEDIR/gmloader"


./gmloader HydorahWrapper.apk | tee log.txt /dev/tty0

$ESUDO kill -9 "$(pidof gptokeyb)"
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1
printf "\033c" > /dev/tty0
