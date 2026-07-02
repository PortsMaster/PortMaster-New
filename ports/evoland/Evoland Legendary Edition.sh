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

# Block unsupported operating systems
if [ -f "/etc/trimui_device.txt" ]; then
    pm_message "This Operating System is not supported by PortMaster.  Please install either Knulli or muOS.  Thank You."
    sleep 15
    exit 1
fi

# Variables
GAMEDIR="/$directory/ports/evoland"

# Check for game files — need sdlboot.dat + at least one pak
# Allow GOG installer as an alternative (patcher will extract it)
HAS_GOG_INSTALLER="no"
for file in "$GAMEDIR"/gamedata/setup_evoland_legendary_edition_1.0*.exe "$GAMEDIR"/setup_evoland_legendary_edition_1.0*.exe; do
    if [ -f "$file" ]; then
        HAS_GOG_INSTALLER="yes"
        break
    fi
done

if [ ! -f "$GAMEDIR/gamedata/sdlboot.dat" ] || [ ! -f "$GAMEDIR/gamedata/evo2.pak" ]; then
    if [ "$HAS_GOG_INSTALLER" = "no" ]; then
        pm_message "Game files not found. Place the GOG installer (.exe and .bin) or copy sdlboot.dat and all .pak files into evoland/gamedata/"
        sleep 15
        exit 1
    fi
fi

# Run patcher if needed (version must match)
PATCH_VERSION="5"
if [ ! -f "$GAMEDIR/gamedata/.patched_complete" ] || [ "$(cat "$GAMEDIR/gamedata/.patched_complete")" != "$PATCH_VERSION" ]; then
    export PATCHER_FILE="$GAMEDIR/patch/patch.bash"
    export PATCHER_GAME="Evoland Legendary Edition"
    export PATCHER_TIME="10-30 minutes"
    export PATCHER_QUESTIONS="$GAMEDIR/tools/questions.lua"

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

# CD to gamedata/ — game loads PAK files from CWD
cd "$GAMEDIR/gamedata"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs.aarch64:$LD_LIBRARY_PATH"
# Mesa optimizations
export LIBGL_NOERROR=1
export MESA_NO_ERROR=1

# Apply language from patcher selection
if [ -f "$GAMEDIR/gamedata/.lang" ]; then
    export LANG="$(cat "$GAMEDIR/gamedata/.lang")"
fi

# Run it — AOT compiled binary (compiled on-device during patching)
$GPTOKEYB "evoland" &
pm_platform_helper "$GAMEDIR/gamedata/evoland" > /dev/null
"${GAMEDIR}/gamedata/evoland"

# Clean up after ourselves
pm_finish
