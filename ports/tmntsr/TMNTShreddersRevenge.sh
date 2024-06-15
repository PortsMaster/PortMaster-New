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
export gameassembly="TMNT.exe"
export gamedir="/$directory/ports/tmntsr"
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
$ESUDO rm -rf ~/.local/share/Tribute\ Games/TMNT
mkdir -p ~/.local/share/Tribute\ Games/
ln -sfv "$gamedir/savedata" ~/.local/share/Tribute\ Games/TMNT

# Remove all the dependencies in favour of system libs - e.g. the included 
rm -f System*.dll mscorlib.dll FNA.dll Mono.*.dll

# Setup path and other environment variables
# export FNA_PATCH="$gamedir/dlls/PanzerPaladinPatches.dll"
export MONO_IOMAP=all
export XDG_DATA_HOME=$HOME/.local/share
export MONO_PATH="$gamedir/dlls":"$gamedir/gamedata":"$gamedir/monomod"
export LD_LIBRARY_PATH="$gamedir/libs":"$monodir/lib":"$LD_LIBRARY_PATH"
export PATH="$monodir/bin":"$PATH"

# Configure the renderpath
export FNA3D_FORCE_DRIVER=OpenGL
export FNA3D_OPENGL_FORCE_ES3=1
export FNA3D_OPENGL_FORCE_VBO_DISCARD=1
export FNA_SDL2_FORCE_BASE_PATH=0

sha1sum -c "${gamedir}/gamedata/.ver_checksum"
if [ $? -ne 0 ]; then
	echo "Checksum fail or unpatched binary found, patching game..." 2>&1 | tee /dev/tty0
	rm -f "${gamedir}/gamedata/.astc_done"
	rm -f "${gamedir}/gamedata/.patch_done"
fi

if [[ ! -f "${gamedir}/gamedata/.astc_done" ]] || [[ ! -f "${gamedir}/gamedata/.patch_done" ]]; then
	chmod +x ../progressor ../repack.src ../utils/*
	../progressor \
		--log "../repack.log" \
		--font "../FiraCode-Regular.ttf" \
		--title "First Time Setup" \
		../repack.src

	[[ $? != 0 ]] && exit -1
fi

# Fix for a goof on previous on the previous patcher...
if [[ -f "${gamedir}/gamedata/MONOMODDED_ParisEngine.dll.so" ]]; then
	mv "${gamedir}/gamedata/MONOMODDED_ParisEngine.dll.so" "${gamedir}/gamedata/ParisEngine.dll.so"
	mv "${gamedir}/gamedata/MONOMODDED_${gameassembly}.so" "${gamedir}/gamedata/${gameassembly}.so"
fi

printf "\033c" > /dev/tty0
echo "Loading... Please Wait." > /dev/tty0

$GPTOKEYB "mono" &
$TASKSET mono --ffast-math -O=all ../MMLoader.exe MONOMODDED_${gameassembly} 2>&1 | tee ${gamedir}/log.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
$ESUDO umount "$monodir"

# Disable console
printf "\033c" >> /dev/tty1

