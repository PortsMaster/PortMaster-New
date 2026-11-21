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

GAMEDIR="/$directory/ports/twill"
BINARY=twill.${DEVICE_ARCH}

cd "$GAMEDIR" || exit 1

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# KNULLI's battery saver mutes the sound after minutes without a button press; Twill holds it off
# with this file while a song plays.
PAUSE=/var/run/battery-saver/twill.pause
[ -d "${PAUSE%/*}" ] && export TWILL_KEEP_AWAKE="$PAUSE"

$ESUDO chmod +x "$GAMEDIR/$BINARY"

$GPTOKEYB2 "$BINARY" > /dev/null 2>&1 &

pm_platform_helper "$GAMEDIR/$BINARY"

./"$BINARY"
rm -f "$PAUSE"

pm_finish
