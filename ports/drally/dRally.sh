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

source $controlfolder/control.txt # We source the control.txt file contents here

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

PORTDIR="/$directory/ports"
GAMEDIR="$PORTDIR/drally"
cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

## RUN SCRIPT HERE
if [ -f "DeathRallyWin_10.exe" ]; then
  pm_message "Extracting DeathRallyWin_10.exe"
  $ESUDO ./7z e -y DeathRallyWin_10.exe
  $ESUDO rm -f DeathRallyWin_10.exe
fi

if [ ! -f "TR0.BPA" ]; then
  pm_message "Game files missing, check README for installation instructions."
  sleep 5
  exit
fi

pm_message "Starting game."

$GPTOKEYB "drally_linux" -c drally.gptk textinput &
pm_platform_helper "$GAMEDIR/drally_linux"
./drally_linux

pm_finish
