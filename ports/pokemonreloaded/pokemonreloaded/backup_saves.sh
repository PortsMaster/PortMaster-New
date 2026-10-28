#!/bin/bash
set -u

src="$(cd "$(dirname "$0")" && pwd)"
dst="${GM8_SAVE_BACKUP_DIR:-$src/saves-backup}"
stamp="$(date +%Y%m%d-%H%M%S)"
backup="$dst/$stamp"

mkdir -p "$backup/partidas" 2>/dev/null || exit 0

if [ -d "$src/data/partidas" ]; then
    while IFS= read -r save; do
        cp -p "$save" "$backup/partidas/" 2>/dev/null || true
    done < <(find "$src/data/partidas" -maxdepth 1 -type f -print 2>/dev/null)
fi

while IFS= read -r save; do
    cp -p "$save" "$backup/" 2>/dev/null || true
done < <(find "$src" -maxdepth 1 -type f \
    \( -iname '*.sav' -o -iname '*.srm' -o -iname '*.save' -o -iname '*.savc' \) \
    -print 2>/dev/null)
