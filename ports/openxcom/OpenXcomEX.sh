#!/bin/bash
# PORTMASTER: openxcom.zip, OpenXcomEX.sh

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt

get_controls

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

GAMEDIR=/$directory/ports/openxcom
export TEXTINPUTINTERACTIVE="Y"
export TEXTINPUTNOAUTOCAPITALS="Y"
cd $GAMEDIR

$GPTOKEYB  "openxcom" $HOTKEY textinput -c "./openxcom.$ANALOGSTICKS.gptk" &
LD_LIBRARY_PATH="$PWD/libs" ./openxcom -data "$PWD/data"  -user "$PWD/user" -config "$PWD/config" 2>&1 | tee -a ./log.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1
