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

GAMEDIR=/$directory/ports/blacksouls2
BINARY=mkxp-z.${DEVICE_ARCH}

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [ ! -f "$GAMEDIR/Game.rgss3a" ] && [ ! -d "$GAMEDIR/Data" ]; then
  pm_message "Game files not found. Copy them into $GAMEDIR first, see README.md."
  sleep 5
  exit 1
fi

if [ ! -d "$GAMEDIR/stdlib" ]; then
  gunzip -c "$GAMEDIR/stdlib.tar.gz" | tar xf - -C "$GAMEDIR"
fi

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
if [ -z "${SDL_GAMECONTROLLERCONFIG_FILE:-}" ] && [ "${#sdl_controllerconfig}" -lt 100000 ]; then
  export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
fi

$GPTOKEYB2 "$BINARY" -c "$GAMEDIR/blacksouls2.ini" &

pm_platform_helper "$GAMEDIR/$BINARY"

./$BINARY

pm_finish
