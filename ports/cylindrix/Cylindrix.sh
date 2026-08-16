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

source "$controlfolder/control.txt"


[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls


GAMEDIR="/$directory/ports/cylindrix"
CONFDIR="$GAMEDIR/conf/"

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

export SDL_HINT_VIDEO_X11_FORCE_EGL=1

mkdir -p "$CONFDIR"
cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

ARCHIVE_FILE="assets.tar.gz"
if [[ -f "$ARCHIVE_FILE" ]]; then
    if [[ -d '3d_data/' || -d 'FLI/' || -d 'gamedata/' || -d 'music/' || -d 'pcx_data/' || -d 'stats/' || -d 'utils/' || -d 'wav_data/' ]]; then
        pm_message "Removing old game data"
        $ESUDO rm -fR '3d_data/' 'FLI/' 'gamedata/' 'music/' 'pcx_data/' 'stats/' 'utils/' 'wav_data/'
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

export XDG_DATA_HOME="$CONFDIR"
bind_directories ~/.cylindrix "$GAMEDIR/conf/.cylindrix"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

pm_platform_helper "$GAMEDIR/cylindrix.${DEVICE_ARCH}"

$GPTOKEYB "cylindrix.${DEVICE_ARCH}" -c "./cylindrix.gptk" &
./cylindrix.${DEVICE_ARCH}

pm_finish