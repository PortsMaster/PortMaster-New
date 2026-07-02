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

GAMEDIR="/$directory/ports/omnispeak"

KEENDIR="$GAMEDIR/data/keen7"

if [ ! -f "$KEENDIR/OMNISPK.CFG" ]; then
    $ESUDO cp "$GAMEDIR/defaults" "$KEENDIR/OMNISPK.CFG"
    $ESUDO chmod ugo+rw "$KEENDIR/OMNISPK.CFG"
fi

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO chmod +x "$GAMEDIR/omnispeak.${DEVICE_ARCH}"

$GPTOKEYB "omnispeak.${DEVICE_ARCH}" -c "$GAMEDIR/omnispeak.gptk" &
pm_platform_helper "$GAMEDIR/omnispeak.${DEVICE_ARCH}"
cd $KEENDIR
"$GAMEDIR/omnispeak.${DEVICE_ARCH}" /NOJOYS /EPISODE mod.ck4 

pm_finish
