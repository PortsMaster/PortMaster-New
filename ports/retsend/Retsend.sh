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

source "$controlfolder/control.txt"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR=/$directory/ports/retsend/

BINNAME="retsend.${DEVICE_ARCH:-aarch64}"
[ -x "$GAMEDIR/$BINNAME" ] || BINNAME="retsend"
if [ ! -x "$GAMEDIR/$BINNAME" ]; then
  echo "ERROR: no runnable retsend binary found in $GAMEDIR" >&2
  exit 1
fi
BIN="$GAMEDIR/$BINNAME"

cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export HOME="$GAMEDIR"
export XDG_DATA_HOME="$GAMEDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Set savedir to the ROMs root by default
savedir="/$directory"
for romsdir in ROMS roms Roms; do
  if [ -d "$savedir/$romsdir" ]; then
    savedir="$savedir/$romsdir"
    break
  fi
done

export RETSEND_DATA_DIR="$GAMEDIR/data"
export RETSEND_SAVE_DIR="$savedir"
export RETSEND_PANIC_FILE="$GAMEDIR/retsend-panic.log"
#export RETSEND_LOG_FILE="$GAMEDIR/retsend.log"
#export RETSEND_LOG_LEVEL=debug

$GPTOKEYB "$BINNAME" &
pm_platform_helper "$BIN"
"$BIN"

pm_finish
