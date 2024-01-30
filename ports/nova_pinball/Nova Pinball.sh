#!/bin/bash
# PORTMASTER: nova_pinball.zip, Nova Pinball.sh

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

GAMEDIR=/$directory/ports/nova_pinball
cd $GAMEDIR

if [ "$DEVICE_NAME" = "RGB30" ]; then
  sed -i 's/t.window.width = [0-9]*/t.window.width = '"$DISPLAY_WIDTH"'/' game/conf.lua
  sed -i 's/t.window.height = [0-9]*/t.window.height = '"$DISPLAY_HEIGHT"'/' game/conf.lua
fi

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "love" -c "./game.gptk" &
LD_LIBRARY_PATH="$PWD/libs" ./love game 2>&1 | tee -a ./log.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0