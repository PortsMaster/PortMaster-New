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

GAMEDIR=/$directory/ports/amuletsarmor
BINARY=amuletsarmor.${DEVICE_ARCH}

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

ARCHIVE_FILE="gamedata.tar.gz"
if [[ -f "$ARCHIVE_FILE" ]]; then
    if [[ -d 'gamedata/' ]]; then
        pm_message "Removing old game data"
        $ESUDO rm -fR 'gamedata/'
    fi
    pm_message "Extracting game data, this can take a few minutes..."
    if [ "$CFW_NAME" = "muOS" ]; then
        if gunzip -c "$ARCHIVE_FILE" | tar xf -; then
            pm_message "Extraction successful."
            $ESUDO rm -f "$ARCHIVE_FILE"
        else
            pm_message "Error: Extraction failed."
            sleep 5
            exit 1
        fi
    else
        if tar -xzf "$ARCHIVE_FILE"; then
            pm_message "Extraction successful."
            $ESUDO rm -f "$ARCHIVE_FILE"
        else
            pm_message "Error: Extraction failed."
            sleep 5
            exit 1
        fi
    fi
elif [ ! -d 'gamedata/' ]; then
    pm_message "Error: No data directory present and Archive file $ARCHIVE_FILE not found."
    sleep 5
    exit 1
fi

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

export OMNI_MODE=buffered
export OMNI_EVENT_MODE=auto
export OMNI_EMIT_RETURN=0
export OMNI_UP_KEY=W
export OMNI_DOWN_KEY=S
export OMNI_LEFT_KEY=A
export OMNI_RIGHT_KEY=D
export OMNI_CHARSET_KEY="Space"

if [ "${DISPLAY_WIDTH:-640}" -gt 1280 ]; then
  sed -i "s/^deadzone_scale = .*/deadzone_scale = 18/" "$GAMEDIR/amuletsarmor.ini"
fi

$GPTOKEYB2 "amuletsarmor" -c "$GAMEDIR/amuletsarmor.ini" &

pm_platform_helper "$GAMEDIR/$BINARY"

LD_PRELOAD="$GAMEDIR/libs.${DEVICE_ARCH}/libomni_osk.so${LD_PRELOAD:+:$LD_PRELOAD}" ./$BINARY

pm_finish
