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
get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

$ESUDO chmod 666 /dev/tty0

GAMEDIR="/$directory/ports/labyrinthoflegendaryloot"
cd $GAMEDIR

export XDG_DATA_HOME="$GAMEDIR/conf"
export XDG_CONFIG_HOME="$GAMEDIR/conf"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
mkdir -p "$XDG_DATA_HOME"

# We log the execution of the script into log.txt
exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [ -f "./gamedata/LabyrinthOfLegendaryLoot.exe" ]; then
    GAMEFILE="LabyrinthOfLegendaryLoot.exe"
elif [ -f "./gamedata/LabyrinthOfLegendaryLoot-1.12.love" ]; then
    GAMEFILE="LabyrinthOfLegendaryLoot-1.12.love"
else
  printf "Game files missing, check installation instructions."
  exit
fi

$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "love" -c "./labyrinthoflegendaryloot.gptk" &
./love ./gamedata/$GAMEFILE

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0