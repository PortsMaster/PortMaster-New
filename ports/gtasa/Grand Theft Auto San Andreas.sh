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
cd "$GAMEDIR/gtasa" || exit 1

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export XDG_DATA_HOME="$CONFDIR"
export LD_LIBRARY_PATH="$GAMEDIR/gtasa/libs.${DEVICE_ARCH}:$GAMEDIR/gtasa:${LD_LIBRARY_PATH:-}"
export SDL_GAMECONTROLLERCONFIG="${sdl_controllerconfig:-${SDL_GAMECONTROLLERCONFIG:-}}"

if [ "${DEVICE_ARCH:-}" != "aarch64" ]; then
    pm_message "GTA SA requires an AArch64 device."
    pm_finish
    exit 1
fi

if [ ! -f "$GAMEDIR/gtasa/libGame.so" ]; then
    pm_message "Copy the official arm64-v8a libGame.so into $GAMEDIR/gtasa/."
    pm_finish
    exit 1
fi

chmod +x "$GAMEDIR/gtasa/gtasa_linux" 2>/dev/null || true
pm_platform_helper "$GAMEDIR/gtasa/gtasa_linux"
"$GAMEDIR/gtasa/gtasa_linux"
status=$?
pm_finish
exit "$status"
