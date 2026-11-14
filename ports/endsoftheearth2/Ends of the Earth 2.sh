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

GAMEDIR="/$directory/ports/endsoftheearth2"
CONFDIR="$GAMEDIR/conf/"
DATAFILE="EOTE2.RPG"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

mkdir -p "$GAMEDIR/conf"

# EOTE2.RPG is copyrighted game data and must be supplied by the user; see README.md.
if [ ! -f "$GAMEDIR/$DATAFILE" ]; then
  pm_show_error "Missing $DATAFILE. See README.md for where to get it, then place it in $GAMEDIR/$DATAFILE." --title "Game files missing" --type warning
  exit 1
fi

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTINTERACTIVE="Y"
export XDG_DATA_HOME="$CONFDIR"

# Use ROCKNIX's bundled GeneralUser.sf2 for OHRRPGCE MIDI playback when available.
[ -f "/usr/share/soundfonts/GeneralUser.sf2" ] && export SDL_SOUNDFONTS="/usr/share/soundfonts/GeneralUser.sf2"

cd $GAMEDIR

bind_directories "$HOME/.ohrrpgce" "$CONFDIR"

$GPTOKEYB "ohrrpgce-game" -c ./endsoftheearth2.gptk &
# not all CFWs' control.txt define this (e.g. older PortMaster on some ArkOS installs) -- guard it
command -v pm_platform_helper >/dev/null 2>&1 && pm_platform_helper "$GAMEDIR/ohrrpgce-game"
"./ohrrpgce-game" $DATAFILE -f

pm_finish
