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

if [[ ${CFW_NAME} != ROCKNIX ]]; then
  # GL4ES is not needed on rocknix

  if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
    source "${controlfolder}/libgl_${CFW_NAME}.txt"
  else
    source "${controlfolder}/libgl_default.txt"
  fi

  if [ "$LIBGL_FB" != "" ]; then
    export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es.aarch64/libGL.so.1"
    export SDL_VIDEO_EGL_DRIVER="$GAMEDIR/gl4es.aarch64/libEGL.so.1"
  fi
fi

$GPTOKEYB "$BINARY" -c "./$BINARY.gptk" &

pm_platform_helper "$GAMEDIR/$BINARY"

./$BINARY

pm_finish
