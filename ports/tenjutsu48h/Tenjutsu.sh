#!/bin/bash
# PORTMASTER: tenjutsu48h.zip, Tenjutsu.sh

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

# Variables
GAMEDIR="/$directory/ports/tenjutsu48h"
HASHLINK="$GAMEDIR/hashlink/hl"

# CD and set log
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/hashlink:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# remove this line if you want the crt filter
export TENJUTSU_CRT_DISABLED=1

# Run it
$GPTOKEYB "tenjutsu" & 
pm_platform_helper "tenjutsu" > /dev/null

# swap this out to toggle between AOT and hashlink jit
#${HASHLINK} ${GAMEDIR}/client.hl
${GAMEDIR}/tenjutsu

# Cleanup
pm_finish
