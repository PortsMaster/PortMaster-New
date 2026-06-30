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

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR=/$directory/ports/superbloodhockey
CONFDIR="$GAMEDIR/conf/"

mkdir -p "$GAMEDIR/conf"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Mono runtime
monodir="$HOME/mono"
monofile="$controlfolder/libs/mono-6.12.0.122-aarch64.squashfs"
$ESUDO mkdir -p "$monodir"
$ESUDO umount "$monofile" || true
$ESUDO mount "$monofile" "$monodir"

# Save data
bind_directories ~/.config/SuperBloodHockey "$CONFDIR/savedata"

export MONO_IOMAP=all
export MONO_PATH="$GAMEDIR/gamedata/lib64":"$GAMEDIR/dlls"
export PATH="$monodir/bin":"$PATH"
export LD_LIBRARY_PATH="$GAMEDIR/libs":"$controlfolder/libs":"$monodir/lib":$LD_LIBRARY_PATH
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# GL4ES setup
rm -f $GAMEDIR/libs/libGL.so.1 $GAMEDIR/libs/libEGL.so.1

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [[ "$LIBGL_ES" != "" ]]; then
  export SDL_VIDEO_GL_DRIVER="${GAMEDIR}/gl4es/libGL.so.1"
  export SDL_VIDEO_EGL_DRIVER="${GAMEDIR}/gl4es/libEGL.so.1"
fi

cd "$GAMEDIR/gamedata"

# Patch exe for 640x480 and 720x720
python3 "$GAMEDIR/scripts/patch_sbh.py" "SuperBloodHockey.exe"

$GPTOKEYB "mono" &
pm_platform_helper "$GAMEDIR/gamedata/SuperBloodHockey.exe"
$TASKSET mono "SuperBloodHockey.exe"

$ESUDO umount "$monodir"
pm_finish
