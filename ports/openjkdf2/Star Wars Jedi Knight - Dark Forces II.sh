#!/bin/bash

export OPENJKDF2_MOTS=0

export OPENJKDF2_HUD_SCALE=2.0
# Optional handheld cheats submenu in pause menu (single-player only):
export OPENJKDF2_CHEATS_MENU=1

# Debug: simulate another panel resolution (logical render + letterbox on real screen).
# Formats: 480x320  720x720  480,320
# export OPENJKDF2_FORCE_RES=640x480

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

PORTDIR="$(cd "$(dirname "$0")" && pwd)"
GAMEDIR="$PORTDIR/openjkdf2"
export GAMEDIR
. "$PORTDIR/.openjkdf2.launch.inc"
