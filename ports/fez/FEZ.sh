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
source $controlfolder/tasksetter

GAMEDIR="/$directory/ports/fez"
cd "$GAMEDIR/gamedata"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Setup mono
monodir="$HOME/mono"
monofile="$controlfolder/libs/mono-6.12.0.122-aarch64.squashfs"
$ESUDO mkdir -p "$monodir"
$ESUDO umount "$monofile" || true
$ESUDO mount "$monofile" "$monodir"

# Saves, logs and settings live alongside the port
mkdir -p "$GAMEDIR/savedata"
bind_directories "$HOME/.local/share/FEZ" "$GAMEDIR/savedata"
bind_directories "$HOME/.config/FEZ" "$GAMEDIR/conf"

# Drop the bundled 2016 Mono and FNA in favour of the runtime and the FNA in dlls/
rm -f System*.dll mscorlib.dll Mono.*.dll FNA.dll FNA.dll.config

export FNA_PATCH="$GAMEDIR/dlls/FezPatches.dll"
export MONO_PATH="$GAMEDIR/dlls"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
export PATH="$monodir/bin:$PATH"

export FNA3D_FORCE_DRIVER=OpenGL
export FNA3D_OPENGL_FORCE_ES3=1

$GPTOKEYB2 "mono" &
pm_platform_helper "mono"
$TASKSET mono FEZ.exe

pm_finish
