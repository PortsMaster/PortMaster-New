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

GAMEDIR=/$directory/ports/babbeu

mkdir -p "$GAMEDIR/conf/.bab"
cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

bind_directories "$XDG_DATA_HOME/love/bab" "$GAMEDIR/conf/.bab"

source "$controlfolder/runtimes/love_11.5/love.txt"

$GPTOKEYB2 "love.${DEVICE_ARCH}" -c "$GAMEDIR/babbeu.ini" &

$LOVE_RUN "$GAMEDIR/babbeu.love"

pm_finish
