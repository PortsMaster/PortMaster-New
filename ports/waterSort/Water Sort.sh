#!/bin/bash
XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
if   [ -d "/opt/system/Tools/PortMaster/" ]; then
    controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
    controlfolder="/opt/tools/PortMaster"
elif [ -d "/roms/ports/PortMaster/" ]; then
    controlfolder="/roms/ports/PortMaster"
else
    controlfolder="/roms2/ports/PortMaster"
fi

source "$controlfolder/control.txt"
get_controls

GAMEDIR="/$directory/ports/watersort"
cd "$GAMEDIR" || { echo "ERROR: $GAMEDIR not found" > /dev/tty1; exit 1; }
# Redirect all stdout/stderr to log
exec > "$GAMEDIR/log.txt" 2>&1
# Audio: force ALSA on RK3326
export SDL_AUDIODRIVER=alsa

$ESUDO chmod +x "$GAMEDIR/watersort"
"$GAMEDIR/watersort"
