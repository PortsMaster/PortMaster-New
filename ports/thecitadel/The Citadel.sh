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

# Drain shutdown messages even when the whole launcher's process group is stopped.
> "$GAMEDIR/log.txt" && exec > >(trap '' HUP INT TERM; exec tee "$GAMEDIR/log.txt") 2>&1

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export SDL_TOUCH_MOUSE_EVENTS=0
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

game_pid=
mapper_pid=

# Stop the game before pm_finish releases its input mapper.
stop_child() {
  local pid="$1"
  [ -n "$pid" ] || return 0
  if kill -0 "$pid" 2>/dev/null; then
    kill -TERM "$pid" 2>/dev/null
    for attempt in {1..30}; do
      kill -0 "$pid" 2>/dev/null || break
      sleep 0.1
    done
    kill -KILL "$pid" 2>/dev/null
  fi
  wait "$pid" 2>/dev/null || true
}

cleanup() {
  local status=$?
  trap - EXIT
  trap '' HUP INT TERM
  stop_child "$game_pid"
  pm_finish
  return "$status"
}

trap cleanup EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

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
mapper_pid=$!
pm_platform_helper "$GAMEDIR/$BINARY"

./$BINARY &
game_pid=$!

# A dead mapper must not leave an uncontrollable game covering the frontend.
if ! kill -0 "$mapper_pid" 2>/dev/null; then
  wait "$mapper_pid"
  exit $?
fi
wait -n "$game_pid" "$mapper_pid"
exit $?
