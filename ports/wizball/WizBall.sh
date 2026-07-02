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


GAMEDIR="/$directory/ports/wizball"
# If $directory is empty (some CFWs don't set it), derive GAMEDIR from
# the script's own location: script lives at ports/WizBall.sh so the
# port folder is the wizball/ sibling directory.
if [ ! -d "$GAMEDIR" ]; then
  GAMEDIR="$(dirname "$(readlink -f "$0")")/wizball"
fi
cd "$GAMEDIR" || { echo "FATAL: cannot cd to $GAMEDIR" > /tmp/wizball_fatal.txt; exit 1; }

# Simple redirect to logfile - avoid process substitution (unreliable on embedded shells)
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
echo "GAMEDIR=$GAMEDIR"
echo "CFW_NAME=${CFW_NAME}"

# SDL controller mapping provided by PortMaster
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

BIN="wizball.aarch64"

echo "BIN=$BIN  exists=$(test -f "$BIN" && echo yes || echo NO)"

# PortMaster helper (sets up env / permissions / etc.)
pm_platform_helper "$GAMEDIR/$BIN"
cd $GAMEDIR
chmod +x "$BIN"

# Set renderer backend to GLES2 - this is the most compatible option across all devices, and the fallback if Vulkan support is spotty.
WIZBALL_RENDERER_BACKEND=gles2

# Start keymapper for this binary (kill-mode hotkey support)
export LD_LIBRARY_PATH="$controlfolder:$LD_LIBRARY_PATH"
$GPTOKEYB2 "$BIN" -c "./wizball.ini" &
./$BIN

echo "Binary exited with code $?"

pm_finish
