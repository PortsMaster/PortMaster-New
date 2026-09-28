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

GAMEDIR=/$directory/ports/powermanga
BINARY=powermanga.${DEVICE_ARCH}

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
elif [ ! -f 'graphics/256_colors_palette.bin' ]; then
    pm_message "Error: No game data present and archive file $ARCHIVE_FILE not found."
    sleep 5
    exit 1
fi

mkdir -p "$GAMEDIR/conf"
export XDG_CONFIG_HOME="$GAMEDIR/conf"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$GPTOKEYB2 "powermanga" -c "./powermanga.ini" &

pm_platform_helper "$GAMEDIR/$BINARY"

"$GAMEDIR/$BINARY" --fullscreen

pm_finish
