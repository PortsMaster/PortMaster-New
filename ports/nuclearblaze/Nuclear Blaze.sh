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

# Variables
GAMEDIR="/$directory/ports/nuclearblaze"

# Check for game files
if [ ! -f "$GAMEDIR/gamedata/hlboot.dat" ] || [ ! -f "$GAMEDIR/gamedata/res.pak" ]; then
    pm_message "Game files not found. Copy hlboot.dat and res.pak into the nuclearblaze/gamedata/ folder."
    sleep 15
    exit 1
fi

# Run patcher if needed (version must match)
PATCH_VERSION="3"
if [ ! -f "$GAMEDIR/gamedata/.patched_complete" ] || [ "$(cat "$GAMEDIR/gamedata/.patched_complete")" != "$PATCH_VERSION" ]; then
    export PATCHER_FILE="$GAMEDIR/patch/patch.bash"
    export PATCHER_GAME="Nuclear Blaze"
    export PATCHER_TIME="5-15 minutes"

    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        $ESUDO chmod a+x "$GAMEDIR/patch/patch.bash"
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb)
    else
        echo "This port requires the latest version of PortMaster."
        sleep 5
        exit 1
    fi

    if [ ! -f "$GAMEDIR/gamedata/.patched_complete" ]; then
        echo "Patching failed"
        sleep 5
        exit 1
    fi
fi

# CD to gamedata/ — both Steam and itch variants load res.pak from CWD
# (Steam's "../res" path is patched to ".//res" by nb-patch-all)
cd "$GAMEDIR/gamedata"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs.aarch64:$LD_LIBRARY_PATH"
# Mesa optimizations
export LIBGL_NOERROR=1
export MESA_NO_ERROR=1

# Run it — AOT compiled binary (compiled on-device during patching)
$GPTOKEYB "nuclearblaze" &
pm_platform_helper "$GAMEDIR/gamedata/nuclearblaze" > /dev/null
"${GAMEDIR}/gamedata/nuclearblaze"

# Clean up after ourselves
pm_finish
