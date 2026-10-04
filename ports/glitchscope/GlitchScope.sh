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

GAMEDIR="/$directory/ports/glitchscope"
mkdir -p "$GAMEDIR/music"
cd "$GAMEDIR" || exit 1

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
pm_message "Loading GlitchScope... (Compiling shaders)"

$GPTOKEYB "glitchscope.${DEVICE_ARCH}" &

$ESUDO chmod +x "$GAMEDIR/glitchscope.${DEVICE_ARCH}"
pm_platform_helper "$GAMEDIR/glitchscope.${DEVICE_ARCH}"

# Some audiocodec images leave the MIC1 capture path disabled at boot.
# Only touch this card when it exposes the matching mixer control.
if command -v amixer >/dev/null 2>&1 &&
   amixer -c audiocodec cget name='ADCL Input MIC1 Boost Switch' >/dev/null 2>&1; then
  amixer -c audiocodec cset name='ADCL Input MIC1 Boost Switch' on >/dev/null ||
    echo "Warning: could not enable MIC1 capture input"
fi

./glitchscope.${DEVICE_ARCH} -fullscreen

pm_finish
