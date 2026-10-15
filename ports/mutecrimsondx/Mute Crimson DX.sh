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
source $controlfolder/tasksetter
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/mutecrimsondx"

cd "$GAMEDIR/gamedata"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Make patchscript executable
chmod +x "$GAMEDIR/tools/patchscript"

# First-run patching
if [ ! -f install_completed ]; then
    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        export controlfolder
        export ESUDO
        export DEVICE_ARCH
        export GAMEDIR
        export PATCHER_FILE="$GAMEDIR/tools/patchscript"
        export PATCHER_GAME="Mute Crimson DX"
        export PATCHER_TIME="a short while..."
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb) 2>/dev/null
    else
        pm_message "This port requires the latest version of PortMaster."
    fi
fi

# .NET 8 ARM64 runtime (mounted with $ESUDO, since mount needs root)

netdir="$HOME/dotnet8"
netfile="$controlfolder/libs/dotnet-8.0.12.squashfs"

cleanup_runtime() {
    $ESUDO umount "$netdir" 2>/dev/null
}

mkdir -p "$netdir"

# Clear any stale mount from a previous crashed run
cleanup_runtime

$ESUDO mount "$netfile" "$netdir"

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to mount .NET 8 runtime:"
    echo "$netfile"
    echo "ESUDO='$ESUDO' uid=$(id -u)"
    pm_finish
    exit 1
fi

if [ ! -x "$netdir/dotnet" ]; then
    echo "ERROR: dotnet executable not found in:"
    echo "$netdir"
    ls -la "$netdir"
    cleanup_runtime
    pm_finish
    exit 1
fi

# Tell .NET where the ARM64 runtime is located
export DOTNET_ROOT="$netdir"
export DOTNET_ROOT_ARM64="$netdir"

# Runtime/native libraries
export LD_LIBRARY_PATH="$netdir:$GAMEDIR/libs:/usr/config/emuelec/lib:/usr/lib:$LD_LIBRARY_PATH"

# Make the mounted runtime's dotnet the first one found
export PATH="$netdir:$GAMEDIR/libs:$PATH"

# Save data
bind_directories "$HOME/.local/share/MuteCrimsonDX" "$GAMEDIR/savedata"

# FNA / SDL exports
export FNA3D_FORCE_DRIVER=OpenGL
export FNA3D_OPENGL_FORCE_ES3=1
export FNA_SDL2_FORCE_BASE_PATH=0

export SDL_NO_SIGNAL_HANDLERS=1
export SDL_TOUCH_MOUSE_EVENTS=0
export SDL_MOUSE_TOUCH_EVENTS=0

# Launch
"$netdir/dotnet" --info

$GPTOKEYB "dotnet" &
pm_platform_helper "$netdir/dotnet"

$TASKSET "$netdir/dotnet" "$GAMEDIR/gamedata/MuteCrimsonDX.dll"

# Cleanup
cleanup_runtime
pm_finish
