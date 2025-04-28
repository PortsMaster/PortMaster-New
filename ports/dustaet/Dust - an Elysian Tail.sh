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
source $controlfolder/tasksetter
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# Variables
export ASSEMBLY="DustAET.exe"
export GAMEDIR="/$directory/ports/dustaet"
cd "$GAMEDIR"

# Log the execution of the script, the script overwrites itself on each launch
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Setup mono
monodir="$HOME/mono"
monofile="$controlfolder/libs/mono-6.12.0.122-aarch64.squashfs"
$ESUDO mkdir -p "$monodir"
$ESUDO umount "$monofile" || true
$ESUDO mount "$monofile" "$monodir"

# Setup savedir linux
bind_directories "$HOME/.local/share/DustAET" "$GAMEDIR/savedata"

# Remove bundled .NET libraries to use system versions
rm -f "$GAMEDIR"/gamedata/{System*.dll,mscorlib.dll,FNA.dll,Mono.*.dll}

# Setup path and other environment variables
export MONO_IOMAP=all
export XDG_DATA_HOME=$HOME/.local/share
export MONO_PATH="$GAMEDIR/dlls":"$GAMEDIR/gamedata"
export LD_LIBRARY_PATH="$GAMEDIR/libs":"$monodir/lib":"$LD_LIBRARY_PATH"
export PATH="$monodir/bin":"$PATH"

# Configure the renderpath
export FNA3D_FORCE_DRIVER=OpenGL
export FNA3D_OPENGL_FORCE_ES3=1
export FNA3D_OPENGL_FORCE_VBO_DISCARD=1
export FNA_SDL2_FORCE_BASE_PATH=0
export SDL_NO_SIGNAL_HANDLERS=1


# Not patched? Let's perform first-time setup
if [[ ! -f "$GAMEDIR/gamedata/MONOMODDED_DustAET.exe" ]]; then
    export PATCHER_FILE="$GAMEDIR/tools/patchscript"
    export PATCHER_GAME="Dust: An Elysian Tail"
    export PATCHER_TIME="15 to 25 minutes"
    export MONOMOD_MODS="$GAMEDIR/patches"
    export MONOMOD_DEPDIRS="${MONO_PATH}":"${GAMEDIR}/monomod"
    source "$controlfolder/utils/patcher.txt"    
    mono "${GAMEDIR}/monomod/MonoMod.exe" "${GAMEDIR}/gamedata/DustAET.exe"
fi

if [ "$DISPLAY_WIDTH" -lt 960 ] || [ "$DISPLAY_HEIGHT" -lt 664 ]; then
  echo "Low-resolution screen detected. Applying HackSDL configuration."
  export HACKSDL_VERBOSE="1"
  export HACKSDL_CONFIG_FILE="$GAMEDIR/tools/hacksdl.conf"
fi

if echo "$CFW_NAME" | tr '[:upper:]' '[:lower:]' | grep -q ark; then
    # Sound hack for rg351mp/r36
    cp tools/asoundrc ~/.asoundrc
    echo "Sound hack applied for $CFW_NAME"
fi
	
cd "$GAMEDIR/gamedata"

$GPTOKEYB "mono" &
pm_platform_helper "mono"
$TASKSET mono --ffast-math -O=all ../MMLoader.exe ${ASSEMBLY}

# Cleanup any running gptokeyb instances, and any platform specific stuff.
pm_finish