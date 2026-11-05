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
CUR_TTY=/dev/tty0

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

mkdir -p "$GAMEDIR/conf"

# This distribution doesn't (and can't) bundle EOTE2.RPG -- it's the copyrighted
# game data (All Rights Reserved by Valkayree Productions), separate from the
# GPL-licensed OHRRPGCE engine this port ships. See README.md for the
# download link; drop the file here before running.
if [ ! -f "$GAMEDIR/$DATAFILE" ]; then
  $ESUDO chmod 666 $CUR_TTY 2>/dev/null
  printf "\033c" > $CUR_TTY
  echo "Missing $DATAFILE." > $CUR_TTY
  echo "See README.md for where to get it, then place it in:" > $CUR_TTY
  echo "$GAMEDIR/$DATAFILE" > $CUR_TTY
  sleep 8
  printf "\033c" > $CUR_TTY
  exit 1
fi

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTINTERACTIVE="Y"
export XDG_DATA_HOME="$CONFDIR"

# OHRRPGCE's MIDI music needs a GM soundfont for fluidsynth -- without this,
# SDL2_mixer logs "no soundfonts for MIDI playback" and background music (but
# not sound effects) stays silent. Use ROCKNIX's bundled GeneralUser.sf2 if present.
[ -f "/usr/share/soundfonts/GeneralUser.sf2" ] && export SDL_SOUNDFONTS="/usr/share/soundfonts/GeneralUser.sf2"

cd $GAMEDIR

bind_directories "$HOME/.ohrrpgce" "$CONFDIR"

$GPTOKEYB "ohrrpgce-game" -c ./endsoftheearth2.gptk &
# not all CFWs' control.txt define this (e.g. older PortMaster on some ArkOS installs) -- guard it
command -v pm_platform_helper >/dev/null 2>&1 && pm_platform_helper "$GAMEDIR/ohrrpgce-game"
"./ohrrpgce-game" $DATAFILE -f

pm_finish
