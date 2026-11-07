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

GAMEDIR=/$directory/ports/raptorsprint
BINARY=raptorsprint.${DEVICE_ARCH}

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR
$ESUDO chmod +x "$GAMEDIR/$BINARY"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$GPTOKEYB2 "raptorsprint" > /dev/null 2>&1 &
pm_platform_helper "$GAMEDIR/$BINARY"
# Knulli reports the pad by position, not by label, so A is the east button there.
[ "$CFW_NAME" = "knulli" ] && PAD_ARGS="--pad-position"
./$BINARY --res "${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}" $PAD_ARGS

pm_finish
