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

GAMEDIR=/$directory/ports/hover
BINARY=hover.${DEVICE_ARCH}

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [ -z "$(find gamedata -maxdepth 1 -iname hover.exe 2>/dev/null)" ]; then
    pm_show_error "Copy the files from your Hover! folder (HOVER.EXE, DASHRES.DLL, MAZES, SOUNDS) into ports/hover/gamedata." --title "Game files missing"
    exit 1
fi

mkdir -p "$GAMEDIR/conf"

$GPTOKEYB2 "$BINARY" -c "./hover.ini" &

pm_platform_helper "$GAMEDIR/$BINARY"

./$BINARY "$GAMEDIR/gamedata" "$GAMEDIR/conf/hover.reg" "$GAMEDIR/TimGM6mb.sf2"

pm_finish
