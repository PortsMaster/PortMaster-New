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

GAMEDIR=/$directory/ports/gta2/
CONFDIR="$GAMEDIR/conf/"
BINARY="gta2-lan.${DEVICE_ARCH}"

# Patcher config
export PATCHER_FILE="$GAMEDIR/tools/install_gta2"
export PATCHER_GAME="$(basename "${0%.*}")" # This gets the current script filename without the extension
export PATCHER_TIME="1 to 5 minutes"

mkdir -p "$GAMEDIR/conf"
mkdir -p "$GAMEDIR/saves"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

if [ ! -d "$GAMEDIR/gamedata/data" ]; then
  if [ -f "$controlfolder/utils/patcher.txt" ]; then
    source "$controlfolder/utils/patcher.txt"
  else
    pm_message "This port requires the latest version of PortMaster."
  fi
fi

[ -d "$GAMEDIR/gamedata/data" ] || { echo "No game data in gamedata/: see patchlog.txt"; pm_finish; exit 1; }
$GPTOKEYB "${BINARY}" &

pm_platform_helper "$GAMEDIR/${BINARY}"
./${BINARY}
pm_finish