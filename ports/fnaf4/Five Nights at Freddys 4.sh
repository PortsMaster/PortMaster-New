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

GAMEDIR=/$directory/ports/fnaf4
GD="$GAMEDIR/gamedata"
EXE_STD="FiveNightsatFreddys4.exe"
EXE_HE="FiveNightsatFreddys4 HalloweenEdition.exe"
NAME_STD="FNaF 4"
NAME_HE="FNaF 4 Halloween Edition"     

mkdir -p "$GAMEDIR/conf" "$GD" "$GAMEDIR/fnaf4_std" "$GAMEDIR/fnaf4_he"

cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export GAMEPAD_PICKER_OUTPUT="$GAMEDIR/.picker_result"
PICKER="$GAMEDIR/gamepad-picker.${DEVICE_ARCH}"

refresh_state() {
    AVAIL=""
    NEEDS_BUILD=0
    for ed in std he; do
        if [ -f "$GD/.patched_$ed" ] && [ ! -x "$GAMEDIR/fnaf4_$ed/Chowdren" ]; then
            rm -f "$GD/.patched_$ed"         
        fi
        if [ -f "$GD/.patched_$ed" ]; then AVAIL="$AVAIL $ed"; fi
    done
    AVAIL="${AVAIL# }"
    if [ -f "$GD/$EXE_STD" ] && [ ! -f "$GD/.patched_std" ]; then NEEDS_BUILD=1; fi
    if [ -f "$GD/$EXE_HE" ]  && [ ! -f "$GD/.patched_he" ];  then NEEDS_BUILD=1; fi
}

run_patcher() {
    if [ ! -f "$controlfolder/utils/patcher.txt" ]; then
        pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
        sleep 5
        exit 1
    fi
    rm -f "$GAMEDIR/.patch_ok"
    $ESUDO chmod +x "$GAMEDIR/patch/patch.bash" "$GAMEDIR/patch/detect_hw.bash" \
        "$GAMEDIR/patch/apply_source_patches.bash"

    export GAMEDIR controlfolder DEVICE_ARCH
    export PATCHER_FILE="$GAMEDIR/patch/patch.bash"
    export PATCHER_GAME="Five Nights at Freddy's 4"
    export PATCHER_TIME="1-2 hours per version"
    export PATCHER_QUESTIONS="$GAMEDIR/patch/patcher_questions.lua"

    source "$controlfolder/utils/patcher.txt"

    if [ ! -f "$GAMEDIR/.patch_ok" ]; then
        echo "Patching was cancelled or failed."
        sleep 3
        exit 1
    fi
    rm -f "$GAMEDIR/.patch_ok"
}

while true; do
    refresh_state

    if [ -z "$AVAIL" ] && [ "$NEEDS_BUILD" -eq 0 ]; then
        pm_message "Game files not found. Copy FiveNightsatFreddys4.exe and/or the Halloween Edition exe into fnaf4/gamedata."
        sleep 5
        exit 1
    fi

 
    if [ -z "$AVAIL" ]; then
        run_patcher
        continue
    fi

    ARGS=()
    for ed in $AVAIL; do
        if [ "$ed" = std ]; then ARGS+=("$NAME_STD|std"); else ARGS+=("$NAME_HE|he"); fi
    done
    if [ "$NEEDS_BUILD" -eq 1 ]; then ARGS+=("Patch new gamefile|patch"); fi

    
    if [ "${#ARGS[@]}" -eq 1 ]; then
        EDITION="$AVAIL"
        break
    fi

    CHOICE=""
    if [ -x "$PICKER" ]; then
        rm -f "$GAMEPAD_PICKER_OUTPUT"
        "$PICKER" "${ARGS[@]}" > /dev/null
        if [ -f "$GAMEPAD_PICKER_OUTPUT" ]; then read -r CHOICE < "$GAMEPAD_PICKER_OUTPUT"; fi
        rm -f "$GAMEPAD_PICKER_OUTPUT"
    elif [ "$NEEDS_BUILD" -eq 1 ]; then
        CHOICE=patch                         
    fi

    case "$CHOICE" in
        patch)  run_patcher ;;                
        std|he) EDITION="$CHOICE"; break ;;
        *)      EDITION="${AVAIL%% *}"; break ;;   
    esac
done

echo "Launching edition: $EDITION"

BIN="$GAMEDIR/fnaf4_$EDITION/Chowdren"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [ -n "${LIBGL_FB:-}" ] || [ -n "${LIBGL_ES:-}" ]; then
  export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es.aarch64/libGL.so.1"
  export SDL_VIDEO_EGL_DRIVER="$GAMEDIR/gl4es.aarch64/libEGL.so.1"
fi


cd "$GAMEDIR/fnaf4_$EDITION"     

$GPTOKEYB2 "Chowdren" -c "$GAMEDIR/controls.ini" &

pm_platform_helper "$BIN"

$TASKSET "$BIN"

pm_finish
