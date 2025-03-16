#!/bin/bash
# PORTMASTER: pleasedonttouchanything.zip, PleaseDontTouchAnything.sh

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

export PORT_32BIT="Y" # If using a 32 bit port
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR=/$directory/ports/pleasedonttouchanything/
CONFDIR="$GAMEDIR/conf/"
mkdir -p "$CONFDIR"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Patchy McPatchFace
if [ -f "$GAMEDIR/gamedata/data.win" ]; then
  if [ "$ASPECT_X" = 4 ] && [ "$ASPECT_Y" = 3 ]; then
    $controlfolder/xdelta3 -d -s "$GAMEDIR/gamedata/data.win" "patch.xdelta" "$GAMEDIR/gamedata/game.droid"
    rm -f "$GAMEDIR/gamedata/data.win"
  elif [ "$ASPECT_X" = 3 ] && [ "$ASPECT_Y" = 2 ]; then
    $controlfolder/xdelta3 -d -s "$GAMEDIR/gamedata/data.win" "patch2.xdelta" "$GAMEDIR/gamedata/game.droid"
    rm -f "$GAMEDIR/gamedata/data.win"
  elif [ "$ASPECT_X" = 1 ] && [ "$ASPECT_Y" = 1 ]; then
    $controlfolder/xdelta3 -d -s "$GAMEDIR/gamedata/data.win" "patch3.xdelta" "$GAMEDIR/gamedata/game.droid"
    rm -f "$GAMEDIR/gamedata/data.win"
  else
    mv "$GAMEDIR/gamedata/data.win" "$GAMEDIR/gamedata/game.droid"
  fi
fi

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_linux"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO chmod +x "$GAMEDIR/gmloader"

$GPTOKEYB "gmloader" -c ./pleasedonttouchanything.gptk &
pm_platform_helper "gmloader"
./gmloader pleasedonttouchanything.apk

pm_finish
