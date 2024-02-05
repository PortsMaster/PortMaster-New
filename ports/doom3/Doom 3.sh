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
source $controlfolder/device_info.txt
get_controls

GAMEDIR="/$directory/ports/doom3"

cd $GAMEDIR

exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO chmod 666 /dev/uinput

export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$GPTOKEYB "dhewm3" -c "./dhewm3.gptk" &
./dhewm3 +set r_mode "-1" +set r_customWidth "$DISPLAY_WIDTH" +set r_customHeight "$DISPLAY_HEIGHT"

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty0
