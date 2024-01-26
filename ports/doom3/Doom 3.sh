#!/bin/bash
# PORTMASTER: doom3.zip, Doom 3.sh

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt

get_controls

GAMEDIR="/storage/roms/ports/doom3"

cd $GAMEDIR
echo $SDL_GAMECONTROLLERCONFIG_FILE
$GPTOKEYB "dhewm3" -c "./dhewm3.gptk" &
LD_LIBRARY_PATH=./libs:$LD_LIBRARY_PATH ./dhewm3 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
unset LD_PRELOAD
printf "\033c" >> /dev/tty1
