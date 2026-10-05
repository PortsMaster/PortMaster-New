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

GAMEDIR=/$directory/ports/blacksouls
BINARY=mkxp-z.${DEVICE_ARCH}

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# The game is a paid title, so its files are user supplied.
# A copy is either encrypted, with Game.rgss3a, or an unpacked project with a
# loose Data folder. mkxp-z runs both, so accept either.
if [ ! -f "$GAMEDIR/Game.rgss3a" ] && [ ! -d "$GAMEDIR/Data" ]; then
  echo "Game files not found. See README.md for how to supply them."
  echo "Expected: $GAMEDIR/Game.rgss3a or $GAMEDIR/Data/"
  sleep 5
  exit 1
fi

# Ruby's standard library is 1160 files, so it ships packed.
if [ ! -d "$GAMEDIR/stdlib" ]; then
  gunzip -c "$GAMEDIR/stdlib.tar.gz" | tar xf - -C "$GAMEDIR"
fi

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
# Hand SDL the controller database by file, not by value. ROCKNIX's copy of
# $sdl_controllerconfig is the whole 476 KB database, and Linux caps a single
# environment string at 128 KB, so exporting it makes every later exec fail with
# E2BIG - the engine, grep, pkill, all of it. Firmware that sets
# SDL_GAMECONTROLLERCONFIG_FILE has already done this properly; older firmware
# hands over just this device's mapping, which is small and still worth passing.
if [ -z "${SDL_GAMECONTROLLERCONFIG_FILE:-}" ] && [ "${#sdl_controllerconfig}" -lt 100000 ]; then
  export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
fi

$GPTOKEYB2 "$BINARY" -c "$GAMEDIR/blacksouls.ini" &

pm_platform_helper "$GAMEDIR/$BINARY"

./$BINARY

pm_finish
