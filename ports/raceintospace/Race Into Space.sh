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

GAMEDIR=/$directory/ports/raceintospace
BINARY=raceintospace.${DEVICE_ARCH}

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

ARCHIVE_FILES=("data-part1.tar.gz" "data-part2.tar.gz")
if [[ -f "${ARCHIVE_FILES[0]}" || -f "${ARCHIVE_FILES[1]}" ]]; then
    if [[ -d 'data/' ]]; then
        pm_message "Removing old game data"
        $ESUDO rm -fR 'data/'
    fi
    pm_message "Extracting game data, this can take a few minutes..."
    if gunzip -c "${ARCHIVE_FILES[0]}" | tar xf - && gunzip -c "${ARCHIVE_FILES[1]}" | tar xf -; then
        pm_message "Extraction successful."
        $ESUDO rm -f "${ARCHIVE_FILES[@]}"
    else
        pm_message "Error: Extraction failed."
        sleep 5
        exit 1
    fi
elif [ ! -d 'data/' ]; then
    pm_message "Error: No data directory present and archive files not found."
    sleep 5
    exit 1
fi

mkdir -p "$GAMEDIR/saves"

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

export BARIS_DATA="$GAMEDIR/data"
export BARIS_SAVE="$GAMEDIR/saves"

export OMNI_MODE=buffered
export OMNI_EVENT_MODE=auto
export OMNI_EMIT_RETURN=0
export OMNI_FONT="$GAMEDIR/fonts/LiberationSans-Regular.ttf"
export OMNI_FONT_SIZE=24

$GPTOKEYB2 "raceintospace" -c "$GAMEDIR/raceintospace.ini" &

pm_platform_helper "$GAMEDIR/$BINARY"

LD_PRELOAD="$GAMEDIR/libs.${DEVICE_ARCH}/libomni_osk.so${LD_PRELOAD:+:$LD_PRELOAD}" ./$BINARY

pm_finish
