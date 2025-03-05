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

GAMEDIR=/$directory/ports/xmoto
CONFDIR="$GAMEDIR/conf/"
BINARY=xmoto

# ensure dirs exist
mkdir -p "$GAMEDIR/conf/config"
mkdir -p "$GAMEDIR/conf/local"
mkdir -p "$GAMEDIR/conf/cache"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export XDG_DATA_DIRS=$GAMEDIR/share/
export XDG_CONFIG_HOME=$CONFDIR/config
export XDG_DATA_HOME=$CONFDIR/local
export XDG_CACHE_HOME=$CONFDIR/cache

export LD_LIBRARY_PATH="$GAMEDIR/libs.aarch64:$LD_LIBRARY_PATH"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [ "$LIBGL_FB" != "" ]; then
export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es.aarch64/libGL.so.1"
export SDL_VIDEO_EGL_DRIVER="$GAMEDIR/gl4es.aarch64/libEGL.so.1"
fi

export TEXTINPUTPRESET="Portmaster"
export TEXTINPUTINTERACTIVE="Y"

# Calculate dpad_mouse_step and deadzone_scale based on DISPLAY_WIDTH
value=$((4*DISPLAY_WIDTH/480))
echo "Setting dpad_mouse_step and deadzone_scale to $value"
sed -i -E "s/(dpad_mouse_step|deadzone_scale) = .*/\1 = $value/g" \
  "$GAMEDIR"/$BINARY.gptk*

$GPTOKEYB "$BINARY" -c "./$BINARY.gptk" &

pm_platform_helper "$GAMEDIR/$BINARY"

$GAMEDIR/$BINARY --noexts \
  --resolution "$DISPLAY_WIDTH"x"$DISPLAY_HEIGHT" \
  --verbose

pm_finish
