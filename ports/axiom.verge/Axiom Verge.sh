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

GAMEDIR="/$directory/ports/axiom-verge"
cd "$GAMEDIR/gamedata"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Grab text output...
$ESUDO chmod 666 /dev/tty0
printf "\033c" > /dev/tty0

# Setup mono
monodir="$HOME/mono"
monofile="$controlfolder/libs/mono-6.12.0.122-aarch64.squashfs"
$ESUDO mkdir -p "$monodir"
$ESUDO umount "$monofile" || true
$ESUDO mount "$monofile" "$monodir"

# Setup savedir
bind_directories ~/.local/share/AxiomVerge "$GAMEDIR/savedata"

# Remove all the dependencies in favour of system libs - e.g. the included 
# newer version of FNA with patcher included
rm -f System*.dll mscorlib.dll FNA.dll Mono.*.dll

# Setup path and other environment variables
# export FNA_PATCH="$GAMEDIR/dlls/SteelAssaultPatches.dll"
export MONO_PATH="$GAMEDIR/dlls"
export LD_LIBRARY_PATH="$GAMEDIR/libs:/usr/config/emuelec/lib32:/usr/lib32:$LD_LIBRARY_PATH"
export PATH="$monodir/bin:$PATH"

export FNA3D_FORCE_DRIVER=OpenGL
export FNA3D_OPENGL_FORCE_ES3=1

# Sound fix for some devices running ArkOS and/or dArkOS
if [[ "${CFW_NAME^^}" == *"ARKOS"* ]]; then
    if [ ! -f ~/.asoundrc ] && [ -f ~/.asoundrcbak ]; then
        $ESUDO cp ~/.asoundrcbak ~/.asoundrc
        $ESUDO chmod ugo+rw ~/.asoundrc
        sleep 0.5
    fi
fi

$GPTOKEYB "mono" &
$TASKSET mono AxiomVerge.exe

$ESUDO umount "$monodir"

pm_finish
