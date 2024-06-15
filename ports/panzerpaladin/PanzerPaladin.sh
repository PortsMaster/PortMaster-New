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

export ESUDO=$ESUDO
export gameassembly="PanzerPaladin.exe"
export gamedir="/$directory/ports/panzerpaladin"

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
$ESUDO rm -rf ~/.local/share/Tribute\ Games/PanzerPaladin
mkdir -p ~/.local/share/Tribute\ Games/
ln -sfv "$gamedir/savedata" ~/.local/share/Tribute\ Games/PanzerPaladin

rm -f mscorlib.dll FNA.dll Mono.*.dll

# Setup path and other environment variables
export MONO_IOMAP=all
export XDG_DATA_HOME=$HOME/.local/share
export MONO_PATH="$gamedir/dlls":"$gamedir/gamedata"
export LD_LIBRARY_PATH="$gamedir/libs":"$monodir/lib":"$LD_LIBRARY_PATH"
export PATH="$monodir/bin":"$PATH"

# Configure the renderpath
export FNA3D_FORCE_DRIVER=OpenGL
export FNA3D_OPENGL_FORCE_ES3=1
export FNA3D_OPENGL_FORCE_VBO_DISCARD=1
export FNA_SDL2_FORCE_BASE_PATH=0

# Not patched? let's perform first time setup
if [[ ! -f "$gamedir/gamedata/MONOMODDED_ParisEngine.dll" ]]; then	
	echo "Performing first time setup..." 2>&1 | tee /dev/tty0 "${gamedir}/install_log.txt"
	echo "This may take upwards of 5 minutes, please wait." 2>&1 | tee -a /dev/tty0 "${gamedir}/install_log.txt"

	# Configure MonoMod settings
	export MONOMOD_MODS="$gamedir/patches"
	export MONOMOD_DEPDIRS="${MONO_PATH}":"${gamedir}/monomod"

	# Patch the ParisEngine file
	mono "${gamedir}/monomod/MonoMod.exe" "${gamedir}/gamedata/ParisEngine.dll" 2>&1 | tee -a /dev/tty0 "${gamedir}/install_log.txt"
	if [ $? -ne 0 ]; then
		echo "Failure performing first time setup, report this." 2>&1 | tee -a /dev/tty0 "${gamedir}/install_log.txt"
		exit -1
	fi
fi

printf "\033c" > /dev/tty0
echo "Loading... Please Wait." > /dev/tty0

$GPTOKEYB "mono" &
$TASKSET mono --ffast-math -O=all ../MMLoader.exe ${gameassembly} 2>&1 | tee /dev/tty0 "${gamedir}/log.txt"
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
$ESUDO umount "$monodir"

# Disable console
printf "\033c" >> /dev/tty1

