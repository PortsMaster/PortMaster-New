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

GAMEDIR=/$directory/ports/fnaf2
BUILD="$GAMEDIR/build"
BIN="$GAMEDIR/Chowdren"
# Look for an exe file in gamedir (first found)
GAME_EXE=$(find "${GAMEDIR}" -type f -iname "*.exe" -print -quit)
PATCHED_FLAG="$GAMEDIR/gamedata/.patched_complete"

mkdir -p "$GAMEDIR/conf" "$GAMEDIR/gamedata"

NEEDS_BUILD=0
if [ ! -f "$PATCHED_FLAG" ] || [ ! -x "$BIN" ]; then
    NEEDS_BUILD=1
fi

if [ "$NEEDS_BUILD" -eq 1 ]; then
    if [ ! -f "$GAME_EXE" ]; then
        pm_message "Game files not found. Copy FiveNightsatFreddys2.exe into fnaf2/gamedata."
        sleep 15
        exit 1
    fi

    $ESUDO chmod +x "$GAMEDIR/patch/patch.bash" "$GAMEDIR/patch/detect_hw.bash" \
        "$GAMEDIR/patch/apply_source_patches.bash" 2>/dev/null

    export PATCHER_FILE="$GAMEDIR/patch/patch.bash"
    export PATCHER_GAME="Five Nights at Freddy's 2"
    export PATCHER_TIME="20-40 mins"

    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        $ESUDO chmod a+x "$GAMEDIR/patch/patch.bash"
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb) 2>/dev/null
    else
        pm_message "This port requires a newer version of PortMaster (patcher.txt support). Please update PortMaster and try again."
        sleep 15
        exit 1
    fi

    if [ ! -f "$PATCHED_FLAG" ] || [ ! -x "$BIN" ]; then
        echo "Build failed"
        sleep 5
        exit 1
    fi
fi

cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [ -n "${LIBGL_FB:-}" ] || [ -n "${LIBGL_ES:-}" ]; then
  export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es.aarch64/libGL.so.1"
  export SDL_VIDEO_EGL_DRIVER="$GAMEDIR/gl4es.aarch64/libEGL.so.1"
fi

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

$GPTOKEYB2 "Chowdren" -c "$GAMEDIR/controls.ini" &

pm_platform_helper "$BIN"

$TASKSET "$BIN"

$ESUDO kill -9 $(pidof gptokeyb2) 2>/dev/null

pm_finish
