#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/device_info.txt
export PORT_32BIT="Y"

get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

$ESUDO chmod 666 /dev/tty0

GAMEDIR="/$directory/ports/gaugeofrage"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_windows"

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Permissions
$ESUDO chmod 666 /dev/uinput
$ESUDO chmod +x "$GAMEDIR/gmloader"

cd $GAMEDIR

#Patch Game

# Check for extra files to delete
if [ -f "$GAMEDIR/gamedata/Gauge Of Rage.exe" ]; then
   # Delete the redundant files
   rm "$GAMEDIR/gamedata/Gauge Of Rage.exe"
   rm "$GAMEDIR/gamedata/Release Notes.txt"
   rm "$GAMEDIR/gamedata/*.dll"
   rm "$GAMEDIR/gamedata/Place game files here"
fi

# Check for file existence before trying to manipulate them:
[ -f "./gamedata/data.win" ] && mv gamedata/data.win gamedata/game.droid

$GPTOKEYB "gmloader" &

$ESUDO chmod +x "$GAMEDIR/gmloader"

./gmloader gaugeofrage.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
