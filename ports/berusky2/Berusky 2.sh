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

GAMEDIR=/$directory/ports/berusky2
BINARY=berusky2.${DEVICE_ARCH}

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

ARCHIVE_FILES=(gamedata.tar.gz.part*)
if [[ -f "${ARCHIVE_FILES[0]}" ]]; then
    pm_message "Extracting game data, this can take a few minutes..." --title "Please wait"
    [[ -d 'gamedata/' ]] && $ESUDO rm -fR 'gamedata/'
    if ! cat "${ARCHIVE_FILES[@]}" | gunzip -c | tar --no-same-owner -xf -; then
        pm_show_error "Could not extract the game data. Check that there is enough free space, then launch again." --title "Extraction failed"
        exit 1
    fi
    $ESUDO rm -f "${ARCHIVE_FILES[@]}"
elif [ ! -f 'gamedata/data/state.dat' ]; then
    pm_show_error "No game data found and the gamedata archive is missing. Reinstall the port." --title "Game data missing"
    exit 1
fi

mkdir -p "$GAMEDIR/conf/.berusky2/Save/profiles"
[ -f "$GAMEDIR/conf/.berusky2/berusky3d.ini" ] || cp "$GAMEDIR/berusky3d_default.ini" "$GAMEDIR/conf/.berusky2/berusky3d.ini"
bind_directories ~/.berusky2 "$GAMEDIR/conf/.berusky2"

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

if [ "${DISPLAY_WIDTH:-640}" -gt 1280 ]; then
  sed -i "s/^deadzone_scale = .*/deadzone_scale = 18/" "$GAMEDIR/controls.ini"
fi

if [ "$ANALOG_STICKS" = "0" ]; then
  sed -i "s/^r2 = .*/r2 = hold_state dpad_mouse/" "$GAMEDIR/controls.ini"
fi

if [ "$CFW_NAME" = "ROCKNIX" ]; then
  export SDL_TOUCH_MOUSE_EVENTS=0
  swaymsg input type:touch events disabled 2>/dev/null
  swaymsg seat '*' hide_cursor 0 2>/dev/null
  trap 'swaymsg seat "*" hide_cursor 1000 2>/dev/null' EXIT
fi

$GPTOKEYB2 "berusky2" -c "./controls.ini" &

pm_platform_helper "$GAMEDIR/$BINARY"

export OMNI_EVENT_MODE=key
export OMNI_CONFIRM_KEY="Left Ctrl"
export OMNI_BACKSPACE_KEY="Left Shift"

LD_PRELOAD="$GAMEDIR/libs.${DEVICE_ARCH}/libomni_osk.so${LD_PRELOAD:+:$LD_PRELOAD}" ./$BINARY

pm_finish
