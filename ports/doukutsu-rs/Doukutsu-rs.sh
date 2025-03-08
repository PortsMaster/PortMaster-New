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

GAMEDIR=/$directory/ports/doukutsu-rs
CONFDIR="$GAMEDIR/conf/"
BINARY=doukutsu-rs

mkdir -p "$GAMEDIR/conf"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [[ -e $GAMEDIR/data ]]; then
  echo "Game files found"
else
  echo "Game files not found, using Aeon Genesis translation"
  unzip cavestoryen.zip
  mv CaveStory/* .
  rmdir CaveStory
fi

# remove extraneous files
rm -rf Config.dat DoConfig.exe OrgView.exe *.dll

bind_directories ~/.local/share/doukutsu-rs $GAMEDIR/conf

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [ "${CFW_NAME}" != ROCKNIX ] && [ "$LIBGL_FB" != "" ]; then
  # GL4ES is not needed on rocknix -- the binary will use OpenGL when
  # available (panfrost/adreno) and fall back on GLES for libmali.
  # For other platforms, GLES may not work and so GL/gl4es is used
  export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es.aarch64/libGL.so.1"
  export SDL_VIDEO_EGL_DRIVER="$GAMEDIR/gl4es.aarch64/libEGL.so.1"
fi

$GPTOKEYB "$BINARY" -c "./$BINARY.gptk" &

pm_platform_helper "$GAMEDIR/$BINARY"

./$BINARY

pm_finish
