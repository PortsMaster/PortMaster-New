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

get_controls

gameassembly="Bleed.exe"
gamedir="/$directory/ports/bleed"
cd "$gamedir/gamedata"

# Grab text output...
$ESUDO chmod 666 /dev/tty0
printf "\033c" > /dev/tty0
echo "Loading... Please Wait." > /dev/tty0

# Setup mono
monodir="$HOME/mono"
monofile="$controlfolder/libs/mono-6.12.0.122-aarch64.squashfs"
$ESUDO mkdir -p "$monodir"
$ESUDO umount "$monofile" || true
$ESUDO mount "$monofile" "$monodir"

# Setup savedir
$ESUDO rm -rf ~/.local/share/MONOMODDED_Bleed
ln -sfv "$gamedir/savedata" ~/.local/share/MONOMODDED_Bleed

# Remove all the dependencies in favour of system libs - e.g. the included 
# newer version of FNA with patcher included
rm -f System*.dll mscorlib.dll FNA.dll Mono.*.dll

# Setup path and other environment variables
export MONO_PATH="$gamedir/dlls":"$gamedir/gamedata":"$gamedir/monomod"
export LD_LIBRARY_PATH="$gamedir/libs":"$monodir/lib":"$LD_LIBRARY_PATH"
export PATH="$monodir/bin":"$PATH"

export FNA3D_FORCE_DRIVER=OpenGL
export FNA3D_OPENGL_FORCE_ES3=1
export FNA3D_OPENGL_FORCE_VBO_DISCARD=1
regen_checksum=no

sha1sum -c "${gamedir}/gamedata/.ver_checksum"
if [ $? -ne 0 ]; then
	echo "Checksum fail or unpatched binary found, patching game..." 2>&1 | tee /dev/tty0
	rm -f "${gamedir}/gamedata/.patch_done"
fi

# MONOMODDED files not found, let's perform patching
if [[ ! -f "${gamedir}/gamedata/.patch_done" ]]; then
	echo "Performing game patching..." 2>&1 | tee /dev/tty0 "${gamedir}/install_log.txt"

	# Configure MonoMod settings
	export MONOMOD_MODS="$gamedir/patches"
	export MONOMOD_DEPDIRS="${MONO_PATH}":"${gamedir}/monomod"

	# Patch the ParisEngine/gameassembly files
	mono "${gamedir}/monomod/MonoMod.RuntimeDetour.HookGen.exe" "${gamedir}/gamedata/Bleed.exe" 2>&1 | tee -a /dev/tty0 "${gamedir}/install_log.txt"
	mono "${gamedir}/monomod/MonoMod.exe" "${gamedir}/gamedata/Bleed.exe" 2>&1 | tee -a /dev/tty0 "${gamedir}/install_log.txt"
	if [ $? -ne 0 ]; then
		echo "Failure performing first time setup, report this." 2>&1 | tee -a /dev/tty0 "${gamedir}/install_log.txt"
		exit -1
	fi

	# Mark step as done
	touch "${gamedir}/gamedata/.patch_done"
	regen_checksum=yes
fi

# Regenerate sha1sum checks
if [[ x${regen_checksum} -eq xyes ]]; then
	sha1sum "${gamedir}/gamedata/"Bleed.exe > "${gamedir}/gamedata/.ver_checksum"
	sha1sum "${gamedir}/patches/"*.dll >> "${gamedir}/gamedata/.ver_checksum"
fi

$GPTOKEYB "mono" &
$TASKSET mono --ffast-math -O=all MONOMODDED_${gameassembly} 2>&1 | tee /dev/tty0 "${gamedir}/log.txt"
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
$ESUDO umount "$monodir"

# Disable console
printf "\033c" >> /dev/tty1

