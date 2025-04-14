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

GAMEDIR=/$directory/ports/deathroad
SAVEDIR="$GAMEDIR/savedata/"
LD_LIBRARY_PATH="$GAMEDIR/libs.aarch64/"

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Set the XDG environment variables for config & savefiles
export XDG_DATA_HOME="$SAVEDIR"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

# Patch final Level
if [ -f "$GAMEDIR/patch/canada-crossing-region.df" ]; then
  rm -rf "$GAMEDIR/deathforth/events/exterior/region/canada-crossing-region.df" 
  mv "$GAMEDIR/patch/canada-crossing-region.df" "$GAMEDIR/deathforth/events/exterior/region"
fi

# Setup Box64
export LD_LIBRARY_PATH="$GAMEDIR/box64/native":"/usr/lib":"/usr/lib/aarch64-linux-gnu/":"$GAMEDIR/libs/":"$LD_LIBRARY_PATH"
export BOX64_LD_LIBRARY_PATH="$GAMEDIR/box64/x64":"$GAMEDIR/box64/native":"$GAMEDIR/libs/x64"

# Move existing savedata to the port directory to avoid overwriting existing
# saves. 
if [ -d ~/.madgarden ] && [ ! -h ~/.madgarden ]; then
    $ESUDO cp -RT ~/.madgarden "$GAMEDIR/savedata"
fi

if [ "$LIBGL_FB" != "" ]; then
	export SDL_VIDEO_EGL_DRIVER="${GAMEDIR}/gl4es.aarch64/libEGL.so.1"
	export SDL_VIDEO_GL_DRIVER="${GAMEDIR}/gl4es.aarch64/libGL.so.1"
	export SDL_VIDEO_GLU_DRIVER="${GAMEDIR}/libs.aarch64/libGLU.so.1" ##############################
fi

# Setup savedir
bind_directories ~/.madgarden "$GAMEDIR/savedata"

#export BOX64_LOG=1
#export BOX64_DLSYM_ERROR=1
#export BOX64_SHOWSEGV=1
#export BOX64_SHOWBT=1

$GPTOKEYB2 "prog-linux" &
pm_platform_helper "$GAMEDIR/box64/box64"
$GAMEDIR/box64/box64 ./prog-linux

pm_finish