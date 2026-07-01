#!/bin/bash

# ======================
# PortMaster Universal Launcher
# (ArkOS & Rocknix compatible)
# ======================

# Avoid unintended GLX
export SDL_HINT_VIDEO_X11_FORCE_EGL=1

# ======================
# Detect PortMaster control folder
# ======================
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

# ======================
# PortMaster helpers
# ======================
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# ======================
# Directory Setup
# ======================
GAMEDIR="/$directory/ports/cylindrix"
CONFDIR="$GAMEDIR/conf/"

# ======================
# Library Paths
# ======================
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

# ======================
# Prepare Execution
# ======================
mkdir -p "$CONFDIR"
cd "$GAMEDIR" || exit

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export XDG_DATA_HOME="$CONFDIR"
bind_directories ~/.cylindrix "$GAMEDIR/conf/.cylindrix"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# ======================
# Optional fixes for missing platform helpers
# ======================
if type pm_platform_helper >/dev/null 2>&1; then
  pm_platform_helper "$GAMEDIR/cylindrix.${DEVICE_ARCH}"
fi

# ======================
# Launch port
# ======================
$GPTOKEYB "cylindrix.${DEVICE_ARCH}" -c "./cylindrix.gptk" &

./cylindrix.${DEVICE_ARCH}

# ======================
# Cleanup
# ======================
if type pm_finish >/dev/null 2>&1; then
  pm_finish
fi