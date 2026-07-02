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

to_lower_case() {
    find "$1" -depth \( -name "*.PAK" -o -name "PAK0.pak" \) | while IFS= read -r SRC; do
        DST=$(dirname "$SRC")/$(basename "$SRC" | tr '[:upper:]' '[:lower:]')
        TMP_DST=$(dirname "$SRC")/temp_$(basename "$SRC" | tr '[:upper:]' '[:lower:]')
        if [ "$SRC" != "$DST" ]; then
            $ESUDO mv -vf "$SRC" "$TMP_DST"
            $ESUDO mv -vf "$TMP_DST" "$DST"
        fi
    done
}

GAMEDIR="/$directory/ports/darkplaces"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

to_lower_case "$GAMEDIR/id1"

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

bind_directories ~/.darkplaces $GAMEDIR/conf/.darkplaces

$ESUDO chmod +x "$GAMEDIR/darkplaces-sdl.${DEVICE_ARCH}"

if [[ "${DEVICE_NAME^^}" == "X55" ]] || [[ "${DEVICE_NAME^^}" == "RG353P" ]] || [[ "${DEVICE_NAME^^}" == "RG40XX-H" ]] || [[ "${CFW_NAME^^}" == "RETRODECK" ]]; then
    GPTOKEYB_CONFIG="$GAMEDIR/darkplacestriggers.gptk"  
else
    GPTOKEYB_CONFIG="$GAMEDIR/darkplaces.gptk"
fi

# Sound fix for some devices running ArkOS and/or dArkOS
if [[ "${CFW_NAME^^}" == *"ARKOS"* ]]; then
    if [ ! -f ~/.asoundrc ] && [ -f ~/.asoundrcbak ]; then
        $ESUDO cp ~/.asoundrcbak ~/.asoundrc
        $ESUDO chmod ugo+rw ~/.asoundrc
        sleep 0.5
    fi
fi

$GPTOKEYB "darkplaces-sdl.${DEVICE_ARCH}" -c "$GPTOKEYB_CONFIG" &
pm_platform_helper "$GAMEDIR/darkplaces-sdl.${DEVICE_ARCH}"
./darkplaces-sdl.${DEVICE_ARCH} +exec controls.cfg

pm_finish
