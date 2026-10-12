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

GAMEDIR=/$directory/ports/2048plus
CONFDIR="$GAMEDIR/conf/"

mkdir -p "$GAMEDIR/conf"
cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export XDG_DATA_HOME="$CONFDIR"
bind_directories ~/.2048plus $GAMEDIR/conf/.2048plus

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

ARCHIVE_FILE="gamedata.tar.gz"
if [[ -f "$ARCHIVE_FILE" ]]; then
    if gunzip -c "$ARCHIVE_FILE" | tar --no-same-owner -xf -; then
        $ESUDO rm -f "$ARCHIVE_FILE"
    else
        pm_message "Error: Extraction failed."
        sleep 5
        exit 1
    fi
elif [ ! -f 'gamedata/main.lua' ]; then
    pm_message "Error: No game data present and Archive file $ARCHIVE_FILE not found."
    sleep 5
    exit 1
fi

# Ensure any PortMaster message dialog or pugwash background process is closed
if [ -e "$PM_PIPE" ]; then
    PortMasterDialogExit
fi
$ESUDO pkill -9 -f pugwash 2>/dev/null || true
$ESUDO pkill -9 -f text_viewer 2>/dev/null || true
$ESUDO rm -f /dev/shm/portmaster/pm_* /dev/shm/portmaster/pg_* 2>/dev/null || true

if [ ! -z "$(echo "$CUR_TTY" | grep -e '^/dev/tty')" ]; then
    printf "\033c" > "$CUR_TTY"
    printf "\033[?25l" > "$CUR_TTY"
fi

source $controlfolder/runtimes/"love_11.5"/love.txt

$GPTOKEYB "$LOVE_GPTK" &
pm_platform_helper "$LOVE_BINARY"
$LOVE_RUN "$GAMEDIR/gamedata"

pm_finish
