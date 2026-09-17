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

GAMEDIR=/$directory/ports/tuxaqfh
BINARY=tux_aqfh.${DEVICE_ARCH}

mkdir -p "$GAMEDIR/conf"
cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

ARCHIVE_FILE="data.tar.gz"
if [[ -f "$ARCHIVE_FILE" ]]; then
    if [[ -d 'data/' ]]; then
        pm_message "Removing old game data"
        $ESUDO rm -fR data images models mods penguin slamcode wavs fonts
    fi
    pm_message "Extracting game data, this can take a few minutes..."
    if gunzip -c "$ARCHIVE_FILE" | tar xf -; then
        pm_message "Extraction successful."
        $ESUDO rm -f "$ARCHIVE_FILE"
    else
        pm_message "Error: Extraction failed."
        sleep 5
        exit 1
    fi
elif [ ! -d 'data/' ]; then
    pm_message "Error: No data directory present and archive file $ARCHIVE_FILE not found."
    sleep 5
    exit 1
fi

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [[ ":$LD_LIBRARY_PATH:" == *":$GAMEDIR/gl4es.${DEVICE_ARCH}:"* ]]; then
  export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es.${DEVICE_ARCH}/libGL.so.1"
  export SDL_VIDEO_EGL_DRIVER="$GAMEDIR/gl4es.${DEVICE_ARCH}/libEGL.so.1"
fi

export TUX_AQFH_DATADIR="$GAMEDIR"
export TUX_AQFH_RC="$GAMEDIR/conf/.tux_aqfh_rc"

$GPTOKEYB2 "tux_aqfh" -c "$GAMEDIR/tuxaqfh.ini" > /dev/null 2>&1 &

pm_platform_helper "$GAMEDIR/$BINARY"

./$BINARY

pm_finish
