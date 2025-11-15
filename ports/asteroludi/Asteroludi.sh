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

# pm
source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# variables
if [ -z "$directory" ]; then
  GAMEDIR=$(dirname "$0")/asteroludi
  DEVICE_ARCH=`uname -m`
else
  GAMEDIR=/$directory/ports/asteroludi
fi

# enable logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
cd $GAMEDIR

# run the game
pm_platform_helper "./arcajs.${DEVICE_ARCH}"
"./arcajs.${DEVICE_ARCH}" -f asteroludi.ajs

# cleanup
pm_finish
