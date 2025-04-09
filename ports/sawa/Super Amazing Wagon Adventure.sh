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

# Pm
source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls
source $controlfolder/tasksetter  # Tasksetter is needed for handhelds with Big-Little architecture soc's.

# Variables
GAMEDIR="/$directory/ports/sawa"
cd "$GAMEDIR/gamedata"

# Log the execution of the script, the script overwrites itself on each launch
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Rename to fix Windows capitalization
mv Content/FX/CRT.xnb Content/FX/Crt.xnb

# Setup mono
monodir="$HOME/mono"
monofile="$controlfolder/libs/mono-6.12.0.122-aarch64.squashfs"
$ESUDO mkdir -p "$monodir"
$ESUDO umount "$monofile" || true
$ESUDO mount "$monofile" "$monodir"

# Setup savedir linux
bind_directories "$HOME/.local/share/WagonAdventure" "$GAMEDIR/savedata" 

# Setup path and other environment variables
export MONO_PATH="$GAMEDIR/dlls"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
export PATH="$monodir/bin:$PATH"

export FNA3D_FORCE_DRIVER=OpenGL
export FNA3D_OPENGL_FORCE_ES3=1
export FNA3D_OPENGL_FORCE_VBO_DISCARD=1

$GPTOKEYB "mono" &
pm_platform_helper "mono"
$TASKSET mono "WagonAdventure.exe"

# Cleanup any running gptokeyb instances, and any platform specific stuff.
pm_finish


