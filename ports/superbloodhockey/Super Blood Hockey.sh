#!/bin/bash
# PORTMASTER: superbloodhockey.zip, Super Blood Hockey.sh

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
source $controlfolder/device_info.txt
source $controlfolder/tasksetter

get_controls

gamedir="/$directory/ports/superbloodhockey"
cd "$gamedir/"

$ESUDO chmod 666 /dev/tty0
printf "\033c" > /dev/tty0
echo "Loading... Please Wait." > /dev/tty0

monodir="$HOME/mono"
monofile="$controlfolder/libs/mono-6.12.0.122-aarch64.squashfs"
$ESUDO mkdir -p "$monodir"
$ESUDO umount "$monofile" || true
$ESUDO mount "$monofile" "$monodir"

bind_directories ~/.config/SuperBloodHockey "$gamedir/savedata"

export MONO_IOMAP=all
export MONO_PATH="$gamedir/gamedata/lib64":"$gamedir/dlls"
export PATH="$monodir/bin":"$PATH"
export LD_LIBRARY_PATH="$gamedir/libs":"/usr/lib":"/lib":"$controlfolder/libs":"$monodir/lib":$LD_LIBRARY_PATH

rm -f $gamedir/libs/libGL.so.1 $gamedir/libs/libEGL.so.1

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [[ "$LIBGL_ES" != "" ]]; then
        export SDL_VIDEO_GL_DRIVER="${gamedir}/gl4es/libGL.so.1"
        export SDL_VIDEO_EGL_DRIVER="${gamedir}/gl4es/libEGL.so.1"
fi

cd "$gamedir/gamedata"

# Patch exe for 640x480 (replaces 3840x2160). After patching, go to
# Settings > Display and select 640x480 once — it stays saved.
python3 "$gamedir/scripts/patch_sbh.py" "SuperBloodHockey.exe"

gameassembly="SuperBloodHockey.exe"

$GPTOKEYB "mono" &
$TASKSET mono "${gameassembly}" 2>&1 | tee "${gamedir}/log.txt"

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
$ESUDO umount "$monodir"

printf "\033c" >> /dev/tty1
