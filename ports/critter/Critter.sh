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

GAMEDIR=/$directory/ports/critter
BINARY=critter.${DEVICE_ARCH}

mkdir -p "$GAMEDIR/conf/.critter"
cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

ARCHIVE_FILE="data.tar.gz"
if [[ -f "$ARCHIVE_FILE" ]]; then
    if [[ -d 'data/' ]]; then
        pm_message "Removing old game data"
        $ESUDO rm -fR 'data/'
    fi
    pm_message "Extracting game data, this can take a few minutes..."
    if gunzip -c "$ARCHIVE_FILE" | tar xf -; then
        pm_message "Extraction successful."
        $ESUDO rm -f "$ARCHIVE_FILE"
    else
        pm_message "Error: Extraction failed."
        sleep 5
        exit 1
    fi
elif [ ! -d 'data/' ]; then
    pm_message "Error: No data directory present and Archive file $ARCHIVE_FILE not found."
    sleep 5
    exit 1
fi

bind_directories ~/.critter "$GAMEDIR/conf/.critter"

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$GPTOKEYB2 "critter" -c "./critter.ini" &

pm_platform_helper "$GAMEDIR/$BINARY"

export OMNI_MODE=buffered
export OMNI_EVENT_MODE=auto

LD_PRELOAD="$GAMEDIR/libs.${DEVICE_ARCH}/libomni_osk.so${LD_PRELOAD:+:$LD_PRELOAD}" ./$BINARY

pm_finish
