#!/bin/bash
XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
if   [ -d "/opt/system/Tools/PortMaster/" ]; then controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ];        then controlfolder="/opt/tools/PortMaster"
else                                              controlfolder="/roms/ports/PortMaster"; fi

source $controlfolder/control.txt
get_controls

GAMEDIR="/roms/ports/WaterSort"
cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export SDL_VIDEO_DRIVER=offscreen   # skip Mali entirely
export SDL_AUDIODRIVER=alsa
export LD_LIBRARY_PATH="/usr/lib/aarch64-linux-gnu:$LD_LIBRARY_PATH"

$ESUDO ./WaterSort
