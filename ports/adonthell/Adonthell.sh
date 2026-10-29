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

GAMEDIR=/$directory/ports/adonthell
BINARY=adonthell.${DEVICE_ARCH}

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

ARCHIVE_FILE="gamedata.tar.gz"
if [[ -f "$ARCHIVE_FILE" ]]; then
    pm_message "Extracting game data, this can take a few minutes..." --title "Please wait"
    if ! gunzip -c "$ARCHIVE_FILE" | tar --no-same-owner -xf -; then
        pm_show_error "Could not extract $ARCHIVE_FILE. Check that there is enough free space, then launch again." --title "Extraction failed"
        exit 1
    fi
    $ESUDO rm -f "$ARCHIVE_FILE"
elif [ ! -f 'share/adonthell/games/wastesedge/gamename.txt' ]; then
    pm_show_error "No game data found and $ARCHIVE_FILE is missing. Reinstall the port." --title "Game data missing"
    exit 1
fi

mkdir -p "$GAMEDIR/conf/adonthell"
bind_directories "${XDG_CONFIG_HOME:-$HOME/.config}/adonthell" "$GAMEDIR/conf/adonthell"
bind_directories "${XDG_DATA_HOME:-$HOME/.local/share}/adonthell" "$GAMEDIR/conf/adonthell"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export PYTHONHOME="$GAMEDIR/python"

export OMNI_BACKSPACE_KEY="Escape"
export OMNI_CHARSET_KEY="]"
export OMNI_FONT="$GAMEDIR/share/adonthell/games/wastesedge/gfx/window/font/Aclonica.ttf"
export OMNI_SHIFT_KEY="PageUp"

$GPTOKEYB2 "adonthell" -c "./adonthell.ini" &

pm_platform_helper "$GAMEDIR/bin/$BINARY"

LD_PRELOAD="$GAMEDIR/libs.${DEVICE_ARCH}/libomni_osk.so${LD_PRELOAD:+:$LD_PRELOAD}" ./bin/$BINARY wastesedge

pm_finish
