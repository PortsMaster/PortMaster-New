#!/bin/bash
# PORTMASTER:chromium_bsu.zip, Chromium BSU.sh
EXE_NAME=chromium-bsu
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

GAMEDIR=/$directory/ports/chromium_bsu
CONFDIR="$GAMEDIR/conf/"
mkdir -p "$CONFDIR"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH:/usr/lib/gl4es"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO chmod +x "$GAMEDIR/bin/$EXE_NAME.$DEVICE_ARCH"

# If a port uses GL4ES (libgl.so.1) a folder named gl4es.aarch64 etc. needs to be created with the libgl.so.1 file in it. This makes sure that each cfw and device get the correct GL4ES export.
if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

$GPTOKEYB "$EXE_NAME.${DEVICE_ARCH}" -c "$GAMEDIR/chromium-bsu.gptk" &
#$GPTOKEYB "$EXE_NAME.${DEVICE_ARCH}" xbox360 &
pm_platform_helper "$GAMEDIR/bin/$EXE_NAME"
cd $GAMEDIR/bin
./$EXE_NAME.$DEVICE_ARCH
cd $GAMEDIR

pm_finish
