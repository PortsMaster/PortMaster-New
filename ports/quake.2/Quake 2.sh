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
    find "$1" -depth \( -name "*.PAK" -o -name "PAK0.pak" -o -name "PAK1.pak" -o -name "PAK2.pak" \) | while IFS= read -r SRC; do
        DST=$(dirname "$SRC")/$(basename "$SRC" | tr '[:upper:]' '[:lower:]')
        TMP_DST=$(dirname "$SRC")/temp_$(basename "$SRC" | tr '[:upper:]' '[:lower:]')
        echo "SRC: $SRC"
        echo "DST: $DST"
        echo "TMP_DST: $TMP_DST"
        if [ "$SRC" != "$DST" ]; then
            echo "Renaming $SRC to $TMP_DST"
            $ESUDO mv -vf "$SRC" "$TMP_DST"
            echo "Renaming $TMP_DST to $DST"
            $ESUDO mv -vf "$TMP_DST" "$DST"
        else
            echo "- $SRC is already lowercase"
        fi
    done
}

GAMEDIR="/$directory/ports/quake2"

$ESUDO chmod 777 -R $GAMEDIR/*

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

to_lower_case "$GAMEDIR/baseq2"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

if [[ "$DISPLAY_WIDTH" == '480' ]]; then
    SSCALE="1"
else
    SSCALE="3"
fi

if [[ "${CFW_NAME^^}" == 'JELOS' ]] || [[ "${CFW_NAME^^}" == 'ROCKNIX' ]]; then
    YQ2RENDERER="soft"
    GUNFOV="82"
else
    YQ2RENDERER="gles3"
    GUNFOV="70"
fi

CFW_NAME=$(echo "$CFW_NAME" | tr '[:lower:]' '[:upper:]')
if [[ "$CFW_NAME" == 'JELOS' ]] || [[ "$CFW_NAME" == 'ROCKNIX' ]]; then
    YQ2RENDERER="soft"
    GUNFOV="82"
else
    YQ2RENDERER="gles3"
    GUNFOV="70"
fi

# Check device type
if [ "$DEVICE_NAME" = "X55" ] || [ "$DEVICE_NAME" = "RG353P" ] || [ "$DEVICE_NAME" = "RG40XX" ]; then
    if [ ! -f "$GAMEDIR/conf/.yq2/console_history.txt" ]; then
        mkdir -p "$GAMEDIR/conf/.yq2"
        cp -rf "$GAMEDIR/conf/yq2_triggers/"* "$GAMEDIR/conf/.yq2/."
    fi
elif [ "$ANALOG_STICKS" -lt 2 ]; then
    if [ ! -f "$GAMEDIR/conf/.yq2/console_history.txt" ]; then
        mkdir -p "$GAMEDIR/conf/.yq2"
        cp -rf "$GAMEDIR/conf/yq2_nosticks/"* "$GAMEDIR/conf/.yq2/."
    fi
else
    if [ ! -f "$GAMEDIR/conf/.yq2/console_history.txt" ]; then
        mkdir -p "$GAMEDIR/conf/.yq2"
        cp -rf "$GAMEDIR/conf/yq2_default/"* "$GAMEDIR/conf/.yq2/."
    fi
fi

bind_directories ~/.yq2 $GAMEDIR/conf/.yq2

$GPTOKEYB "quake2" -c "$GAMEDIR/quake2.gptk" &
pm_platform_helper "$GAMEDIR/quake2"
./quake2 +set vid_renderer $YQ2RENDERER +set r_mode -2 +set r_customwidth $DISPLAY_WIDTH +set r_customheight $DISPLAY_HEIGHT +set r_gunfov $GUNFOV +set r_hudscale $SSCALE +set r_menuscale $SSCALE

pm_finish
