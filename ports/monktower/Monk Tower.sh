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

GAMEDIR="/$directory/ports/monktower"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Saves are written to the working directory.
mkdir -p "$GAMEDIR/saves"
cd "$GAMEDIR/saves"

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
# SDL_Renderer picks its driver per device and lands on desktop GL where mesa is present;
# GLES2 is the path every supported device actually has.
export SDL_RENDER_DRIVER=opengles2

$ESUDO chmod +x "$GAMEDIR/monktower.${DEVICE_ARCH}"

# The game reads the pad itself and its menus navigate with the d-pad, so gptokeyb is only
# here for the standard exit hotkey.
$GPTOKEYB "monktower.${DEVICE_ARCH}" &
pm_platform_helper "$GAMEDIR/monktower.${DEVICE_ARCH}"
"$GAMEDIR/monktower.${DEVICE_ARCH}"

pm_finish
