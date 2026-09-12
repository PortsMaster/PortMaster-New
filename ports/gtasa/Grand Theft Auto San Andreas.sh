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

source "$controlfolder/control.txt"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/gtasa"
CONFDIR="$GAMEDIR/conf"
mkdir -p "$CONFDIR"
cd "$GAMEDIR" || exit 1

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export XDG_DATA_HOME="$CONFDIR"
export SDL_GAMECONTROLLERCONFIG="${sdl_controllerconfig:-${SDL_GAMECONTROLLERCONFIG:-}}"

sdl3_mode="${GTASA_SDL3:-bundled}"
sdl3_system=0
if [ "$sdl3_mode" != "bundled" ]; then
    if command -v ldconfig >/dev/null 2>&1 && ldconfig -p 2>/dev/null | grep -q 'libSDL3.so.0'; then
        sdl3_system=1
    elif [ -e /usr/lib/libSDL3.so.0 ] || [ -e /usr/lib/aarch64-linux-gnu/libSDL3.so.0 ] || [ -e /lib/aarch64-linux-gnu/libSDL3.so.0 ]; then
        sdl3_system=1
    fi
fi
if [ "$sdl3_mode" = "system" ] && [ "$sdl3_system" = 0 ]; then
    pm_message "System SDL3 was requested but libSDL3.so.0 was not found."
    pm_finish
    exit 1
fi
if [ "$sdl3_system" = 1 ]; then
    pm_message "Using system SDL3. Set GTASA_SDL3=bundled to use the SDL2 shim."
    if [ -n "${GTASA_SDL_VIDEO_DRIVER:-}" ]; then
        export SDL_VIDEODRIVER="$GTASA_SDL_VIDEO_DRIVER"
    else
        unset SDL_VIDEODRIVER
    fi
    export LD_LIBRARY_PATH="$GAMEDIR:${LD_LIBRARY_PATH:-}"
else
    pm_message "Using bundled SDL3-to-SDL2 shim."
    export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$GAMEDIR:${LD_LIBRARY_PATH:-}"
fi

if [ "${DEVICE_ARCH:-}" != "aarch64" ]; then
    pm_message "GTA SA requires an AArch64 device."
    pm_finish
    exit 1
fi

if [ ! -f "$GAMEDIR/libGame.so" ]; then
    pm_message "Copy the official arm64-v8a libGame.so into $GAMEDIR/."
    pm_finish
    exit 1
fi

chmod +x "$GAMEDIR/gtasa_linux" 2>/dev/null || true
pm_platform_helper "$GAMEDIR/gtasa_linux"
"$GAMEDIR/gtasa_linux"
status=$?
pm_finish
exit "$status"
