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

GAMEDIR=/$directory/ports/thecitadel
BINARY=cytadela.${DEVICE_ARCH}

mkdir -p "$GAMEDIR/conf"
cd "$GAMEDIR" || exit 1

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export CYTADELA_SAVE_DIR="$GAMEDIR/conf"

if [ -f "$controlfolder/libgl_${CFW_NAME}.txt" ]; then
  source "$controlfolder/libgl_${CFW_NAME}.txt"
else
  source "$controlfolder/libgl_default.txt"
fi

# SDL needs explicit wrapper paths only when PortMaster selected GL4ES.
gl4es_dir="$PWD/gl4es.${DEVICE_ARCH}"
case ":${LD_LIBRARY_PATH}:" in
  *":${gl4es_dir}:"*)
    export CYTADELA_PERSISTENT_GL=1
    export SDL_VIDEO_GL_DRIVER="$gl4es_dir/libGL.so.1"
    export SDL_VIDEO_EGL_DRIVER="$gl4es_dir/libEGL.so.1"
    ;;
esac

ARCHIVE_FILE="gamedata.tar.gz"
if [[ -f "$ARCHIVE_FILE" ]]; then
  pm_message "Extracting game data, this can take a few minutes..." --title "Please wait"
  if ! (set -o pipefail; gunzip -c "$ARCHIVE_FILE" | tar --no-same-owner -xf -); then
    pm_show_error "Could not extract $ARCHIVE_FILE. Check that there is enough free space, then launch again." --title "Extraction failed"
    exit 1
  fi
  $ESUDO rm -f "$ARCHIVE_FILE"
elif [ ! -f 'data/tex/Gfx.far' ]; then
  pm_show_error "No game data found and $ARCHIVE_FILE is missing. Reinstall the port." --title "Game data missing"
  exit 1
fi

# Linux process names truncate this executable's name to 15 characters.
$GPTOKEYB2 "${BINARY:0:15}" -c "$GAMEDIR/thecitadel.ini" > /dev/null 2>&1 &
pm_platform_helper "$GAMEDIR/$BINARY"

./$BINARY

pm_finish
