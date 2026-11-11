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

GAMEDIR=/$directory/ports/superoffroad
BINARY=sorp.${DEVICE_ARCH}

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO chmod +x "$GAMEDIR/$BINARY"

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Mappings counted in key-code order (patched SDL2s) are renumbered for SDL3,
# for SORP alone.  gptokeyb is SDL2 and keeps the CFW's numbering: given
# SORP's, it read the TrimUI Brick pad's L1 + R1 as Select + Start, its
# kill, and killed the game.
MAP="$(python3 padmap.py)" || MAP="$SDL_GAMECONTROLLERCONFIG"

$GPTOKEYB2 "$BINARY" > /dev/null 2>&1 &

pm_platform_helper "$GAMEDIR/$BINARY"

SDL_GAMECONTROLLERCONFIG="$MAP" ./$BINARY gamedata

pm_finish
