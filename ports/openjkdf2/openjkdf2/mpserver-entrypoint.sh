#!/bin/bash
set -euo pipefail

GAMEDIR=/opt/openjkdf2
JK_SRC="$GAMEDIR/jk1"
MOTS_SRC="$GAMEDIR/mots"
JK_WORK=/var/lib/openjkdf2/jk1
MOTS_WORK=/var/lib/openjkdf2/mots

stage_if_readonly() {
    local src="$1" dst="$2" label="$3"
    if [[ ! -d "$src" ]]; then
        return 0
    fi
    if touch "$src/.openjkdf2_write_test" 2>/dev/null; then
        rm -f "$src/.openjkdf2_write_test"
        export "$4=$src"
        return 0
    fi
    if [[ ! -d "$dst/resource" && ! -d "$dst/Resource" ]] \
        && [[ ! -d "$dst/episode" && ! -d "$dst/Episode" ]]; then
        echo "Staging read-only $label into container tmpfs (host files unchanged)."
        mkdir -p "$dst"
        cp -a "$src/." "$dst/"
    fi
    export "$4=$dst"
}

needs_mots=0
for arg in "$@"; do
    [[ "$arg" == "--mots" ]] && needs_mots=1
done

stage_if_readonly "$JK_SRC" "$JK_WORK" "JKDF2" OPENJKDF2_ROOT
if [[ $needs_mots -eq 1 ]]; then
    stage_if_readonly "$MOTS_SRC" "$MOTS_WORK" "MOTS" OPENJKMOTS_ROOT
fi

cd "$GAMEDIR"
exec ./run-dedicated.sh --no-steam "$@"
