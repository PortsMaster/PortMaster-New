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

GAMEDIR="/$directory/ports/deadcells"
mkdir -p "$GAMEDIR/gamedata"

# Find game files anywhere in the port folder and move to gamedata/
for f in hlboot.dat res.pak; do
    if [ ! -f "$GAMEDIR/gamedata/$f" ]; then
        FOUND=$(find "$GAMEDIR" -name "$f" -not -path "*/gamedata/*" -print -quit 2>/dev/null)
        if [ -n "$FOUND" ]; then
            echo "Found $f at $FOUND, moving to gamedata/"
            mv "$FOUND" "$GAMEDIR/gamedata/$f"
        fi
    fi
done

# Move any GOG DLC installers found outside gamedata/ into gamedata/
for dlc in $(find "$GAMEDIR" -maxdepth 3 -name "dead_cells_[a-z]*.sh" -not -path "*/gamedata/*" 2>/dev/null); do
    mv "$dlc" "$GAMEDIR/gamedata/"
done

# Check for game files (GOG installer is also acceptable — the patcher extracts it)
gog_installer=$(ls "$GAMEDIR"/gamedata/dead_cells_1_*.sh 2>/dev/null | head -n 1)
if [ ! -f "$GAMEDIR/gamedata/hlboot.dat" ] || [ ! -f "$GAMEDIR/gamedata/res.pak" ]; then
    if [ -z "$gog_installer" ]; then
        pm_message "Game files not found. Copy hlboot.dat and res.pak (or the GOG installer) into the deadcells folder."
        sleep 15
        exit 1
    fi
fi

# On knulli/a133plus, pause battery saver so it doesn't sleep mid-patch
if [ "$CFW_NAME" = "knulli" ] && [ "$DEVICE_CPU" = "a133plus" ]; then
    BATTERY_PAUSE="/var/run/battery-saver/deadcells_patcher.pause"
    mkdir -p /var/run/battery-saver
    touch "$BATTERY_PAUSE"
fi

# Run patcher if needed: fresh install, upgrade recompile, or DLC installation.
# patch.bash handles all cases — step markers in .patch_state/ let it skip
# already-completed steps, so an upgrade only re-runs compilation.
if [ ! -f "$GAMEDIR/gamedata/.patched_complete" ]; then
    PATCHER_TIME="4-8 hours"
elif [ -f "$GAMEDIR/gamedata/.patch-needs-recompile" ]; then
    PATCHER_TIME="20-40 minutes"
elif ls "$GAMEDIR"/gamedata/dead_cells_[a-z]*.sh > /dev/null 2>&1; then
    PATCHER_TIME="~10 seconds"
    PATCHER_GAME="Dead Cells DLC"
    # Remove sentinel so patcher.txt will run the script
    rm -f "$GAMEDIR/gamedata/.patched_complete"
fi

if [ -n "${PATCHER_TIME:-}" ]; then
    # Patcher needs 7zzs for guide extraction — only available in recent PortMaster
    if [ ! -x "${controlfolder}/7zzs.${DEVICE_ARCH}" ]; then
        pm_message "Dead Cells requires the latest version of PortMaster. Please update PortMaster and try again: https://portmaster.games/"
        sleep 15
        exit 1
    fi
    export PATCHER_FILE="$GAMEDIR/patch/patch.bash"
    export PATCHER_GAME="${PATCHER_GAME:-Dead Cells}"
    export PATCHER_TIME

    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        $ESUDO chmod a+x "$GAMEDIR/patch/patch.bash"
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb)
    else
        echo "This port requires the latest version of PortMaster."
        sleep 5
        exit 1
    fi

    # Check if patching succeeded
    if [ ! -f "$GAMEDIR/gamedata/.patched_complete" ]; then
        echo "Patching failed"
        sleep 5
        exit 1
    fi
fi

# Remove battery saver pause (whether or not patcher ran)
[ -n "$BATTERY_PAUSE" ] && rm -f "$BATTERY_PAUSE"

# CD and set log — redirect AFTER patching completes to avoid
# FUSE deadlocks on KNULLI (exFAT) from O_TRUNC during patching.
cd "$GAMEDIR/gamedata"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs.aarch64:$LD_LIBRARY_PATH"
# memory optimization table to presize huge hashmaps
export HL_MAP_PRESIZE_FILE="$GAMEDIR/map_presize.txt"

# Run it
$GPTOKEYB "deadcells" &
pm_platform_helper "$GAMEDIR/gamedata/deadcells" > /dev/null
"$GAMEDIR/gamedata/deadcells"

# Clean up after ourselves
pm_finish
