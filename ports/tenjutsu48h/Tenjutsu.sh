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

# Variables
GAMEDIR="/$directory/ports/tenjutsu48h"
BOX64="$GAMEDIR/box64/box64"
HASHLINK="$GAMEDIR/hashlink/hl"

# CD and set log
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/box64/x64:$GAMEDIR/hashlink:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export BOX64_LD_LIBRARY_PATH="$GAMEDIR/hashlink:$GAMEDIR/hashlink/lib:$LD_LIBRARY_PATH"
export SDL_VIDEODRIVER="x11"

# Run it
$GPTOKEYB "$HASHLINK" xbox360 & 
pm_platform_helper "$HASHLINK" > /dev/null
"$BOX64" "$HASHLINK" client.hl

# Cleanup
pm_finish