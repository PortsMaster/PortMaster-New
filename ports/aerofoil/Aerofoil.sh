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

GAMEDIR=/$directory/ports/aerofoil
CONFDIR="$GAMEDIR/conf/"
BINARY=AerofoilX

mkdir -p "$GAMEDIR/conf"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

bind_directories ~/.local/share/aerofoil $GAMEDIR/conf

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

if [[ ${CFW_NAME} == ROCKNIX ]]; then
  echo Using standard cursor
  export USE_GL_CURSOR=false
else
  # most CFWs will need the GL cursor
  echo Using GL cursor
  export USE_GL_CURSOR=true
fi

$GPTOKEYB "$BINARY" -c "./$BINARY.gptk" &

pm_platform_helper "$GAMEDIR/$BINARY"

./$BINARY

pm_finish
