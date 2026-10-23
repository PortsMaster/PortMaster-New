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
get_controls

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

GAMEDIR=/$directory/ports/godofthunder
BINARY=got.${DEVICE_ARCH}

cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [ ! -f "$GAMEDIR/gamedata/GOTRES.DAT" ] || [ ! -f "$GAMEDIR/gamedata/GOT.EXE" ]; then
  pm_message "Download https://www.adeptsoftware.com/got/gotfree.zip and extract all files into $GAMEDIR/gamedata, then launch again."
  pm_finish
  exit 1
fi

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO chmod +x "$GAMEDIR/$BINARY"
$GPTOKEYB2 "$BINARY" -c "$GAMEDIR/godofthunder.ini" &

pm_platform_helper "$GAMEDIR/$BINARY"

./$BINARY

pm_finish
