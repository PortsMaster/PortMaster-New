#!/bin/bash
# SPDX-License-Identifier: MIT
# First launch: prepare the owner's APK or PC data with the PortMaster JRE.
set -eo pipefail
GAMEDIR="${1:-$(cd -- "$(dirname -- "$0")" && pwd)}"
JAVA_HOME="${2:-${JAVA_HOME:-/tmp/gunslugs-java}}"
if [[ ! -x "$JAVA_HOME/bin/java" ]]; then
    echo "Launch Gunslugs from Ports to load its Java runtime first."
    exit 1
fi
prepare_cp="$GAMEDIR/runtime/prepare/*"
if "$JAVA_HOME/bin/java" -Xmx128m -cp "$prepare_cp" PrepareDevice --check "$GAMEDIR/gamedata"; then
    echo "Prepared Gunslugs game data found."
    exit 0
fi
echo "Preparing Gunslugs game data. Please wait and do not power off."
if [[ -n "${controlfolder:-}" && -f "$controlfolder/PortMasterDialog.txt" ]]; then
    source "$controlfolder/PortMasterDialog.txt"
    PortMasterDialogInit "no-harbour"
    PortMasterDialog "messages_begin"
    PortMasterDialog "message" "Preparing Gunslugs. Please do not power off."
    PortMasterDialog "progress" "Preparing game data" 0 100
fi

status=0
"$JAVA_HOME/bin/java" -Xmx128m -XX:+UseSerialGC \
    "-Djava.io.tmpdir=$GAMEDIR/cache" -cp "$prepare_cp" PrepareDevice "$GAMEDIR" 2>&1 |
    while IFS= read -r line; do
        printf '%s\n' "$line"
        if [[ "$line" == $'GUNSLUGS_PROGRESS\t'* ]] && declare -F PortMasterDialog >/dev/null; then
            IFS=$'\t' read -r marker percent message <<< "$line"
            PortMasterDialog "progress" "$message" "$percent" 100
        fi
    done || status=$?

if declare -F PortMasterDialogExit >/dev/null; then
    PortMasterDialog "progress_clear"
    PortMasterDialogExit
fi
exit "$status"
