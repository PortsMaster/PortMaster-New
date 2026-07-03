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

GAMEDIR=/$directory/ports/openchaos/
RUNTIME_DIR="$GAMEDIR/runtime"
ASSETS_DIR="$GAMEDIR/assets"
CONTROLS_DIR="$GAMEDIR/controls"
BIN="$GAMEDIR/OpenChaos.${DEVICE_ARCH}"

mkdir -p "$RUNTIME_DIR" "$RUNTIME_DIR/home" "$ASSETS_DIR" "$CONTROLS_DIR"

cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export HOME="$RUNTIME_DIR/home"
export XDG_DATA_HOME="$RUNTIME_DIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$GAMEDIR/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
if [ "${SDL_VIDEODRIVER:-}" = "sdl2" ]; then
  unset SDL_VIDEODRIVER
fi
export SDL3SHIM_SDL2_LIB="${SDL3SHIM_SDL2_LIB:-libSDL2-2.0.so.0}"
export OPENCHAOS_GAMEPAD_BINDINGS="${OPENCHAOS_GAMEPAD_BINDINGS:-$CONTROLS_DIR/gamepad.json}"

# Open Chaos reads original game resources from the current working directory.
# Run from assets/ when users placed their game data there. This avoids symlink
# failures on SD-card filesystems that do not support ln -s. If assets/ only has
# the package placeholder, fall back to GAMEDIR for legacy/manual installs.
RUN_DIR="$GAMEDIR"
if [ -d "$ASSETS_DIR/clumps" ] || [ -d "$ASSETS_DIR/data" ] || [ -d "$ASSETS_DIR/levels" ] || [ -f "$ASSETS_DIR/config.ini" ]; then
  RUN_DIR="$ASSETS_DIR"
fi
echo "Open Chaos working directory: $RUN_DIR"

$GPTOKEYB "OpenChaos.${DEVICE_ARCH}" -c "$GAMEDIR/openchaos.gptk" &

pm_platform_helper "$BIN"

cd "$RUN_DIR"
"$BIN"

pm_finish
