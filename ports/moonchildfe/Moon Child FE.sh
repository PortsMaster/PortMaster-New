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

export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

GAMEDIR="/$directory/ports/moonchildfe"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO chmod +x "$GAMEDIR/MoonChildFE"

cd "$GAMEDIR"

$GPTOKEYB "$GAMEDIR/MoonChildFE" -c "$GAMEDIR/moonchildfe.gptk" &
pm_platform_helper "$GAMEDIR/MoonChildFE"
"$GAMEDIR/MoonChildFE"

pm_finish
