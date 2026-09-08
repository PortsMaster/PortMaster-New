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

GAMEDIR=/$directory/ports/alexandria

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

ARCHIVE_FILE="data.tar.gz"
if [[ -f "$ARCHIVE_FILE" ]]; then
    if [[ -d 'python/' || -d 'gfx/' || -d 'levels/' || -d 'music/' || -d 'sounds/' ]]; then
        pm_message "Removing old game data"
        $ESUDO rm -fR 'python/' 'gfx/' 'levels/' 'music/' 'sounds/'
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
elif [ ! -d 'python/' ]; then
    pm_message "Error: No game data present and archive file $ARCHIVE_FILE not found."
    sleep 5
    exit 1
fi

mkdir -p "$GAMEDIR/conf"

game_libs=$GAMEDIR/libs.${DEVICE_ARCH}/:$LD_LIBRARY_PATH

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export PYTHONHOME="$GAMEDIR/python"
export PYTHONPATH="$GAMEDIR/python/lib/python2.7:$GAMEDIR/python/lib/python2.7/site-packages"
export XDG_CONFIG_HOME="$GAMEDIR/conf/config"
export XDG_DATA_HOME="$GAMEDIR/conf/share"

$GPTOKEYB2 "alexandria" -c "./alexandria.ini" &

pm_platform_helper "$GAMEDIR/python/bin/alexandria"

LD_LIBRARY_PATH=$game_libs "$GAMEDIR/python/bin/alexandria" main.py

pm_finish
