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

GAMEDIR=/$directory/ports/dreamchess
BINARY=dreamchess.${DEVICE_ARCH}

mkdir -p "$GAMEDIR/conf/.dreamchess"
cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

bind_directories ~/.dreamchess "$GAMEDIR/conf/.dreamchess"

ARCHIVE_FILE="music.tar.gz"
if [[ -f "$ARCHIVE_FILE" ]]; then
    pm_message "Extracting bonus music pack, this can take a few minutes..."
    if gunzip -c "$ARCHIVE_FILE" | tar xf -; then
        $ESUDO rm -f "$ARCHIVE_FILE"
    fi
fi

export PATH="$GAMEDIR:$PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [ -d "$GAMEDIR/gl4es.${DEVICE_ARCH}" ]; then
  export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es.${DEVICE_ARCH}/libGL.so.1"
  export SDL_VIDEO_EGL_DRIVER="$GAMEDIR/gl4es.${DEVICE_ARCH}/libEGL.so.1"
fi

$GPTOKEYB2 "dreamchess" -c "./dreamchess.ini" &

pm_platform_helper "$GAMEDIR/$BINARY"

./$BINARY

pm_finish
