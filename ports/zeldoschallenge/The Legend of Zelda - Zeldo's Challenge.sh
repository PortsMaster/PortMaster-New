#!/bin/bash

# Source SDL controls
if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi
source $controlfolder/control.txt
get_controls

# Set variables
GAMEDIR="/$directory/ports/zeldoschallenge"

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/lib:/usr/lib"

cd $GAMEDIR

# Setup controls
$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "solarus-run" -c "zeldo1.gptk" & 

# Run the game
echo "Loading, please wait... (might take a while!)" > /dev/tty0
./solarus-run $GAMEDIR/game/*.solarus 2>&1 | tee -a ./"log.txt"
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events & 
printf "\033c" >> /dev/tty1
printf "\033c" > /dev/tty0