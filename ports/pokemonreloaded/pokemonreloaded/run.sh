#!/bin/bash
set -u

cd "$(dirname "$0")" || exit 1
GAMEDIR="$PWD"

GAME_EXE="$GAMEDIR/reloaded.exe"
if [ ! -f "$GAME_EXE" ]; then
    GAME_EXE="$(find "$GAMEDIR" -maxdepth 1 -type f -iname '*.exe' -print -quit 2>/dev/null || true)"
fi

if [ ! -d "$GAMEDIR/data" ] || [ -z "${GAME_EXE:-}" ] || [ ! -f "$GAME_EXE" ]; then
    printf '\nPokemon Reloaded: faltan los archivos del juego.\n'
    printf 'Copia data/ y el .exe original dentro de:\n  %s\n\n' "$GAMEDIR"
    sleep 6
    exit 1
fi

export SDL_VIDEODRIVER=kmsdrm
export SDL_VIDEO_KMSDRM_DEVICE=/dev/dri/card0
export SDL_AUDIODRIVER=alsa
export SDL_GAMECONTROLLERCONFIG_FILE="$GAMEDIR/gamecontrollerdb.txt"
export GM8_SAVE_BACKUP_DIR="${GM8_SAVE_BACKUP_DIR:-$GAMEDIR/saves-backup}"

chmod +x "$GAMEDIR/gm8emulator" 2>/dev/null || true
bash "$GAMEDIR/backup_saves.sh" 2>/dev/null || true

"$GAMEDIR/gm8emulator" "$GAME_EXE" >"$GAMEDIR/log.txt" 2>&1
status=$?

bash "$GAMEDIR/backup_saves.sh" 2>/dev/null || true
exit "$status"
