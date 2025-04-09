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

GAMEDIR=/$directory/ports/doomrpg
CONFDIR="$GAMEDIR/conf/"
BINARY=DoomRPG

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

mkdir -p "$GAMEDIR/conf"

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export XDG_DATA_HOME="$CONFDIR"
export SDL_SOUNDFONTS="$GAMEDIR/gm.sf2"

# Run bartozip and move DoomRPG.zip only if it doesn't exist
if [ ! -f "$GAMEDIR/DoomRPG.zip" ]; then
    (cd "$GAMEDIR/gamedata" && PATH=$PATH:. ./bartozip && mv DoomRPG.zip "$GAMEDIR/") || exit 1
    unzip -d "$GAMEDIR/extracted" "$GAMEDIR/DoomRPG.zip" || exit 1
fi

cd $GAMEDIR

$GPTOKEYB "$BINARY" &
pm_platform_helper "$GAMEDIR/$BINARY"
./$BINARY

pm_finish
