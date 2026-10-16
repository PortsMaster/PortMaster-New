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

GAMEDIR="/$directory/ports/paladog"
BINARY="paladog"

cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Setup permissions
$ESUDO chmod 666 /dev/uinput

# Setup save dir via PortMaster bind helper
mkdir -p "$GAMEDIR/conf"
bind_directories ~/.local/share/paladog "$GAMEDIR/conf"

# Controller config
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Check if game assets are already extracted
if [ ! -f "$GAMEDIR/assets/data/db_0.bin" ] || [ ! -f "$GAMEDIR/assets/atlases/fdat_31.txt" ]; then
    SWF_FILE=""
    if [ -f "$GAMEDIR/gamedata/Paladog.swf" ]; then
        SWF_FILE="$GAMEDIR/gamedata/Paladog.swf"
    elif [ -f "$GAMEDIR/gamedata/paladog.swf" ]; then
        SWF_FILE="$GAMEDIR/gamedata/paladog.swf"
    elif [ -f "$GAMEDIR/Paladog.swf" ]; then
        SWF_FILE="$GAMEDIR/Paladog.swf"
    elif [ -f "$GAMEDIR/paladog.swf" ]; then
        SWF_FILE="$GAMEDIR/paladog.swf"
    fi

    if [ -n "$SWF_FILE" ]; then
        pm_message "Extracting game assets from Paladog.swf, please wait..."
        PYTHON_BIN="python3"
        if ! command -v python3 &>/dev/null; then
            if command -v python &>/dev/null; then
                PYTHON_BIN="python"
            fi
        fi
        $PYTHON_BIN "$GAMEDIR/tools/extract_swf.py" "$SWF_FILE" "$GAMEDIR/assets"
        if [ ! -f "$GAMEDIR/assets/data/db_0.bin" ]; then
            pm_message "Extraction failed. Please check Paladog.swf file."
            sleep 5
            exit 1
        fi
    else
        pm_message "Game file missing! Please place Paladog.swf into paladog/gamedata/"
        sleep 5
        exit 1
    fi
fi

# Launch game
pm_platform_helper "$GAMEDIR/$BINARY"
"./$BINARY"

pm_finish
