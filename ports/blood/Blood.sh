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
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR="/$directory/ports/Blood"
export LD_LIBRARY_PATH="$GAMEDIR/lib:/usr/lib:$LD_LIBRARY_PATH"

GPTOKEYB_CONFIG="$GAMEDIR/nblood.gptk"

bind_directories ~/.config/nblood $GAMEDIR/conf/nblood
cd $GAMEDIR

$GPTOKEYB "nblood" -c $GPTOKEYB_CONFIG &
./nblood 2>&1 | tee $GAMEDIR/log.txt
pm_finish
