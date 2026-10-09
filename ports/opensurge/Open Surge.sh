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

GAMEDIR=/$directory/ports/opensurge
BINARY=opensurge.${DEVICE_ARCH}

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

ARCHIVE_FILE="gamedata.tar.gz"
if [[ -f "$ARCHIVE_FILE" ]]; then
    pm_message "Extracting game data, this can take a few minutes..."
    if gunzip -c "$ARCHIVE_FILE" | tar --no-same-owner -xf -; then
        pm_message "Extraction successful."
        $ESUDO rm -f "$ARCHIVE_FILE"
    else
        pm_message "Error: Extraction failed."
        sleep 5
        exit 1
    fi
elif [ ! -f 'surge.rocks' ]; then
    pm_message "Error: No game data present and archive file $ARCHIVE_FILE not found."
    sleep 5
    exit 1
fi

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

mkdir -p "$GAMEDIR/games"
CHOICES=()
for entry in games/*; do
    case "${entry,,}" in
        *.zip|*.7z) [ -f "$entry" ] || continue ;;
        *) [ -d "$entry" ] || continue ;;
    esac
    name=$(basename "$entry")
    name=${name%.[zZ][iI][pP]}
    name=${name%.7[zZ]}
    CHOICES+=("${name//|/-}|$GAMEDIR/$entry")
done

GAME_ARGS=()
if [ ${#CHOICES[@]} -gt 0 ]; then
    export GAMEPAD_PICKER_OUTPUT="$GAMEDIR/.picker_result"
    if ! ./gamepad-picker.${DEVICE_ARCH} "Surge the Rabbit|" "${CHOICES[@]}" > /dev/null; then
        pm_finish
        exit 0
    fi
    CHOICE=$(head -n 1 "$GAMEPAD_PICKER_OUTPUT")
    [ -n "$CHOICE" ] && GAME_ARGS=(--game "$CHOICE")
fi

$GPTOKEYB2 "opensurge" -c "$GAMEDIR/opensurge.ini" > /dev/null 2>&1 &

pm_platform_helper "$GAMEDIR/$BINARY"

./$BINARY --fullscreen "${GAME_ARGS[@]}"

pm_finish
