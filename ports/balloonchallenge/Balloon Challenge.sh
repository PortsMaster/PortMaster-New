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

GAMEDIR=/$directory/ports/balloonchallenge
BINARY=balloonc.${DEVICE_ARCH}

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

if [ ! -f "$GAMEDIR/gamedata/BALLOONC.EXE" ]; then
  pm_show_error "BALLOONC.EXE is missing from ports/balloonchallenge/gamedata/. Reinstall the port." --title "Game files missing"
  exit 1
fi

$GPTOKEYB2 "balloonc" -c "./balloonchallenge.ini" &

pm_platform_helper "$GAMEDIR/$BINARY"

./$BINARY --data "$GAMEDIR/gamedata" --fullscreen

pm_finish
