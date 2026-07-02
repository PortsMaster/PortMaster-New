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

to_upper_case() {
    find "$1" -depth \( -name "*.ck3" -o -name "*.exe" \) | while IFS= read -r SRC; do
        DST=$(dirname "$SRC")/$(basename "$SRC" | tr '[:lower:]' '[:upper:]')
        TMP_DST=$(dirname "$SRC")/TEMP_$(basename "$SRC" | tr '[:lower:]' '[:upper:]')
        echo "SRC: $SRC"
        echo "DST: $DST"
        echo "TMP_DST: $TMP_DST"
        if [ "$SRC" != "$DST" ]; then
            echo "Renaming $SRC to $TMP_DST"
            $ESUDO mv -vf "$SRC" "$TMP_DST"
            echo "Renaming $TMP_DST to $DST"
            $ESUDO mv -vf "$TMP_DST" "$DST"
        else
            echo "- $SRC is already uppercase"
        fi
    done
}

GAMEDIR="/$directory/ports/chocolate-keen"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

to_upper_case "$GAMEDIR/GAMEDATA/KEEN3"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO chmod +x "$GAMEDIR/chocolate-keen.${DEVICE_ARCH}"

$GPTOKEYB "chocolate-keen.${DEVICE_ARCH}" -c "$GAMEDIR/chocolate-keen.gptk" &
pm_platform_helper "$GAMEDIR/chocolate-keen.${DEVICE_ARCH}"
"$GAMEDIR/chocolate-keen.${DEVICE_ARCH}" -startkeen3

pm_finish
