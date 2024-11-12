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
get_controls

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

GAMEDIR="/$directory/ports/rednukem-dn3d-atomic"
CONFDIR="$GAMEDIR/conf"

cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# set resolution
if [[ -f "$CONFDIR/rednukem/rednukem.cfg" ]]; then
  sed -i -E \
  -e "s/^(\s*ScreenHeight\s*=\s*).*/\1$DISPLAY_HEIGHT/" \
  -e "s/^(\s*ScreenWidth\s*=\s*).*/\1$DISPLAY_WIDTH/" \
  "$CONFDIR/rednukem/rednukem.cfg"
fi

# set data dir 
if [[ -f "$CONFDIR/rednukem/rednukem.cfg" ]]; then
  sed -i -E \
  -e "s/^(\s*ModDir\s*=\s*).*/\1\"$GAMEDIR\/gamedata\"/" \
  "$CONFDIR/rednukem/rednukem.cfg"
fi


bind_directories "$HOME/.config/rednukem" "$CONFDIR/rednukem"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"

$GPTOKEYB "rednukem" &

pm_platform_helper "$GAMEDIR/rednukem"

./rednukem -game_dir "$GAMEDIR/gamedata"

pm_finish