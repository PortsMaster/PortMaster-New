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

GAMEDIR="/$directory/ports/axecop"
CONFDIR="$GAMEDIR/conf/"
DATAFILE="axecop.rpg"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

mkdir -p "$GAMEDIR/conf"

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTINTERACTIVE="Y"
export XDG_DATA_HOME="$CONFDIR"

cd $GAMEDIR

bind_directories "$HOME/.ohrrpgce" "$CONFDIR"

# Rename any .rpg file found to the DATAFILE variable
file=$(find . -maxdepth 1 -type f -name "*.rpg")
# Check if a file was found
if [[ -n "$file" ]]; then
  mv "$file" "tmp.rpg" # FAT32 case rename fix
  mv "tmp.rpg" "$DATAFILE"
  echo "File renamed to $DATAFILE"
else
  echo "No .rpg file found"
fi

$GPTOKEYB "ohrrpgce-game" -c ./axecop.gptk &
pm_platform_helper "$GAMEDIR/ohrrpgce-game"
"./ohrrpgce-game" $DATAFILE -f

pm_finish

