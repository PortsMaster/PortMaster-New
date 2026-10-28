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

if [ -f "$controlfolder/control.txt" ]; then
    source "$controlfolder/control.txt"
    [ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
    get_controls
fi

GAMEDIR="$(cd "$(dirname "$0")" && pwd)/pokemonreloaded"
cd "$GAMEDIR" || exit 1

if [ ! -d "$GAMEDIR/data" ]; then
    printf '\nPokemon Reloaded: faltan los archivos del juego.\n'
    printf 'Copia data/ y el .exe original dentro de:\n  %s\n\n' "$GAMEDIR"
    sleep 6
    exit 1
fi

manual=0
if ! command -v pm_platform_helper >/dev/null 2>&1; then
    manual=1
    if command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet emulationstation; then
        ${ESUDO:-sudo} systemctl stop emulationstation 2>/dev/null || true
    fi
fi

export SDL_GAMECONTROLLERCONFIG="${sdl_controllerconfig:-}"
export GM8_SAVE_BACKUP_DIR="${GM8_SAVE_BACKUP_DIR:-$GAMEDIR/saves-backup}"

if [ "$manual" = 0 ]; then
    pm_platform_helper "$GAMEDIR/gm8emulator"
fi

bash "$GAMEDIR/run.sh"
status=$?

if [ "$manual" = 0 ]; then
    pm_finish
elif command -v systemctl >/dev/null 2>&1; then
    ${ESUDO:-sudo} systemctl start emulationstation 2>/dev/null || true
fi

exit "$status"
