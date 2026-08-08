#!/bin/bash

# pm preamble
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

# variables
GAMEDIR="/$directory/ports/eatgirl"
CONFDIR="$GAMEDIR/conf"

mkdir -p "$CONFDIR/love"
cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# verify love runtime available
runtime="love_11.5"
if [ ! -f "$controlfolder/runtimes/${runtime}/love.txt" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the love_11.5 runtime."
    sleep 5
    exit 1
  fi
  $ESUDO "$controlfolder/harbourmaster" --quiet --no-check runtime_check "${runtime}.squashfs"
fi

if [ ! -f "$GAMEDIR/eatgirl.love" ]; then
  pm_message "ERROR: eatgirl.love not found. Copy it into ports/eatgirl."
  sleep 5
  exit 1
fi

# patch eatgirl.love
if [ ! -f "$GAMEDIR/.patched" ] && [ -f "$GAMEDIR/patch.py" ]; then
  if ! command -v python3 >/dev/null 2>&1; then
    pm_message "ERROR python3 not found, can't patch."
    sleep 5
    exit 1
  elif python3 "$GAMEDIR/patch.py" "$GAMEDIR/eatgirl.love" "$GAMEDIR/eatgirl.love.patched"; then
    pm_message "Patching game ..."
    mv "$GAMEDIR/eatgirl.love.patched" "$GAMEDIR/eatgirl.love"
    touch "$GAMEDIR/.patched"
  else
    rm -f "$GAMEDIR/eatgirl.love.patched"
    pm_message "ERROR: patch failed."
    sleep 5
    exit 1
  fi
fi

# redirect save/config data to conf folder
export XDG_DATA_HOME="$CONFDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# load runtime
source "$controlfolder/runtimes/${runtime}/love.txt"

# run
$GPTOKEYB "$LOVE_GPTK" -c "$GAMEDIR/eatgirl.gptk" &
pm_platform_helper "$LOVE_BINARY"
$LOVE_RUN "$GAMEDIR/eatgirl.love"

# clean up
pm_finish

