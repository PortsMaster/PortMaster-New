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

export gamedir="/$directory/ports/celeste"
export gameassembly="Celeste.exe"
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
bind_directories ~/.local/share/Celeste "$gamedir/savedata"

# Remove all the dependencies in favour of system libs - e.g. the included 
# newer version of FNA with patcher included
rm -f System*.dll mscorlib.dll FNA.dll Mono.*.dll
cp $gamedir/libs/Celeste.exe.config $gamedir/gamedata

# Setup path and other environment variables
export FNA_PATCH="$gamedir/dlls/CelestePatches.dll"
export MONO_PATH="$gamedir/dlls"
export LD_LIBRARY_PATH="$gamedir/libs":"${monodir}/lib":$LD_LIBRARY_PATH
export PATH="$monodir/bin":"$PATH"
export FNA3D_OPENGL_FORCE_ES3=1
export FNA3D_OPENGL_FORCE_VBO_DISCARD=1

# Compress all textures with ASTC codec, bringing massive vram gains
if [[ ! -f "$gamedir/gamedata/.astc_done" ]]; then
	chmod +x ../progressor ../repack.src ../utils/* "$gamedir/celeste-repacker"
	../progressor \
		--log "../repack.log" \
		--font "../FiraCode-Regular.ttf" \
		--title "First Time Setup" \
		../repack.src
	if [[ $? != 0 ]]; then
		exit
	fi
fi

# first_time_setup
$GPTOKEYB "mono" &
$TASKSET mono Celeste.exe 2>&1 | tee "$gamedir/log.txt"
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
$ESUDO umount "$monodir"

# Disable console
printf "\033c" >> /dev/tty1

