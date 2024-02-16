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

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

GAMEDIR="/$directory/ports/am2r"

export LD_LIBRARY_PATH="$GAMEDIR/libs:/usr/lib:/usr/lib32"
$ESUDO rm -rf ~/.config/am2r
ln -sfv $GAMEDIR/conf/am2r/ ~/.config/
cd $GAMEDIR
$GPTOKEYB "gmloader" -c "$GAMEDIR/am2r.gptk" &
./gmloader gamedata/am2r.apk 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof gptokeyb)
unset LD_LIBRARY_PATH
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty1
