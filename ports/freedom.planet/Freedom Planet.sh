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
export PORT_32BIT="Y"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/freedomplanet"

cd "$GAMEDIR/gamedata" 

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [ "$LIBGL_ES" != "" ]; then
	export SDL_VIDEO_EGL_DRIVER="${GAMEDIR}/gl4es/libEGL.so.1"
	export SDL_VIDEO_GL_DRIVER="${GAMEDIR}/gl4es/libGL.so.1"
fi

export BOX86_SDL2_JGUID=1
export BOX86_ALLOWMISSINGLIBS=1
export BOX86_DLSYM_ERROR=1
export BOX86_LOG=1
export BOX86_LD_LIBRARY_PATH="$GAMEDIR/box86/lib:/usr/lib32:./:lib/:lib32/:x86/"
export BOX86_DYNAREC=1

if ! glxinfo | grep -q "OpenGL version string"; then
  export BOX86_FORCE_ES=31
fi

export BOX86_PATH="$GAMEDIR/box86"
export SDL_DYNAMIC_API=libSDL2-2.0.so.0
export LIBGL_NOBANNER=1

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$GAMEDIR/box86/lib:/usr/lib32"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$GPTOKEYB "box86" &
echo "Loading, please wait... (this may take a few moments!)" > /dev/tty0
pm_platform_helper "$GAMEDIR/box86/box86"
"$GAMEDIR/box86/box86" "$GAMEDIR/gamedata/bin32/Chowdren"

pm_finish
