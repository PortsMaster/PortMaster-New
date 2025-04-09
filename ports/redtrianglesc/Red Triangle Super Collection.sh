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
# device_info.txt will be included by default

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR="/$directory/ports/redtrianglesc"
CONFDIR="$GAMEDIR/conf/"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

mkdir -p "$GAMEDIR/conf"

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTINTERACTIVE="Y"
export XDG_DATA_HOME="$CONFDIR"

cd $GAMEDIR

if [ -f "./Paradox.rpg" ]; then
  $controlfolder/xdelta3 -d -s "./Paradox.rpg" "./Paradox_patch.xdelta3" "./Paradox_patched.rpg"
  # Check if Paradox file patched
  if [ -f "./Paradox_patched.rpg" ]; then
    rm -f "./Paradox.rpg"
    mv "./Paradox_patched.rpg" "./Paradox.rpg"
  else
    echo "Paradox.rpg patch failed"
  fi
fi

bind_directories "$HOME/.ohrrpgce" "$CONFDIR"

$GPTOKEYB "ohrrpgce-game" -c ./redtrianglesc.gptk &
pm_platform_helper "$GAMEDIR/ohrrpgce-game"
"./ohrrpgce-game" RTSuperCollection.rpg -f

pm_finish

