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
export gameassembly="MercenaryKings.exe"
export GAMEDIR="/$directory/ports/mercenarykings"

# Move to gamedata folder
cd "$GAMEDIR/gamedata"

# Log the execution of the script, the script overwrites itself on each launch
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Setup mono
monodir="$HOME/mono"
monofile="$controlfolder/libs/mono-6.12.0.122-aarch64.squashfs"
$ESUDO mkdir -p "$monodir"
$ESUDO umount "$monofile" || true
$ESUDO mount "$monofile" "$monodir"

# Setup savedir linux
bind_directories "$HOME/.local/share/Tribute Games" "$GAMEDIR/savedata"


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

# Remove all the dependencies in favour of system libs - e.g. the included 
rm -f System*.dll mscorlib.dll FNA.dll Mono.*.dll

# Not patched? let's perform first time setup
if [[ ! -f "$GAMEDIR/gamedata/MONOMODDED_ParisEngine.dll" ]]; then	
	echo "Performing first time setup..." 2>&1 | tee /dev/tty0 "${GAMEDIR}/install_log.txt"

	# Configure MonoMod settings
	export MONOMOD_MODS="$GAMEDIR/patches"
	export MONOMOD_DEPDIRS="${MONO_PATH}":"${GAMEDIR}/monomod"

	# Patch the ParisEngine file
	mono "${GAMEDIR}/monomod/MonoMod.exe" "${GAMEDIR}/gamedata/ParisEngine.dll" 2>&1 | tee -a /dev/tty0 "${GAMEDIR}/install_log.txt"
	if [ $? -ne 0 ]; then
		echo "Failure performing first time setup, report this." 2>&1 | tee -a /dev/tty0 "${GAMEDIR}/install_log.txt"
		exit -1
	fi
fi

$GPTOKEYB "mono" &
pm_platform_helper "$monodir/bin/mono"
$TASKSET mono --ffast-math -O=all ../MMLoader.exe ${gameassembly}

# Cleanup any running gptokeyb instances, and any platform specific stuff.
pm_finish