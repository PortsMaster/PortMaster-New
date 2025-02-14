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

GAMEDIR=/$directory/ports/dunelegacy
CONFDIR="$GAMEDIR/conf/"
BINARY="dunelegacy"

# Ensure the conf directory exists
mkdir -p "$GAMEDIR/conf"

bind_directories ~/.config/dunelegacy $GAMEDIR/conf

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [[ ${CFW_NAME} == ROCKNIX ]]; then
  # sim-cursor is not needed on rocknix
  cp vanilla/$BINARY .
 else
  # sim-cursor is usually neede on other CFWs
  cp sim-cursor/$BINARY .
 fi

$GPTOKEYB "$BINARY" -c "$BINARY.gptk" &

pm_platform_helper "$GAMEDIR/$BINARY"

./dunelegacy --fullscreen --showlog

pm_finish
