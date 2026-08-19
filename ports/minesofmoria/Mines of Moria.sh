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

GAMEDIR="/$directory/ports/minesofmoria"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Saves, cache and monster memory are written to the working directory.
mkdir -p "$GAMEDIR/saves"
cd "$GAMEDIR/saves"

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
# The game picks the software renderer on desktop-class Linux and honours this
# hint over its own default; devices have GLES2 and no desktop GL.
export SDL_RENDER_DRIVER=opengles2

$ESUDO chmod +x "$GAMEDIR/minesofmoria.${DEVICE_ARCH}"

# Controller input is read by the game itself; gptokeyb only serves the exit hotkey.
$GPTOKEYB "minesofmoria.${DEVICE_ARCH}" &
pm_platform_helper "$GAMEDIR/minesofmoria.${DEVICE_ARCH}"
"$GAMEDIR/minesofmoria.${DEVICE_ARCH}"

pm_finish
