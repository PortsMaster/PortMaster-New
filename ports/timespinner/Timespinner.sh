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

GAMEDIR="/$directory/ports/timespinner"
cd "$GAMEDIR/gamedata"

# Grab text output...
printf "\033c" > /dev/tty0
echo "Loading... Please Wait." > /dev/tty0

# Setup mono
monodir="$HOME/mono"
monofile="$controlfolder/libs/mono-6.12.0.122-aarch64.squashfs"
$ESUDO mkdir -p "$monodir"
$ESUDO umount "$monofile" || true
$ESUDO mount "$monofile" "$monodir"

# Setup savedir
bind_directories ~/.local/share/Timespinner "$GAMEDIR/savedata"

# Remove all the dependencies in favour of system libs - e.g. the included 
# newer version of FNA with patcher included
$ESUDO rm -f System*.dll mscorlib.dll FNA.dll Mono.*.dll

# Remove GOG scripts
$ESUDO rm -f ./*.sh ./support/*.sh ./support/yad/*.sh

# Setup path and other environment variables
# export FNA_PATCH="$GAMEDIR/dlls/SteelAssaultPatches.dll"
export MONO_PATH="$GAMEDIR/dlls"
export LD_LIBRARY_PATH="$GAMEDIR/libs:/usr/config/emuelec/lib32:/usr/lib32:$LD_LIBRARY_PATH"
export PATH="$monodir/bin:$PATH"

export FNA3D_FORCE_DRIVER=OpenGL
export FNA3D_OPENGL_FORCE_ES3=1

isitarkos=$(grep "title=" /usr/share/plymouth/themes/text.plymouth)
if [[ $isitarkos == *"ArkOS"* ]]; then
  $ESUDO perfnorm
fi

$GPTOKEYB "mono" &
$TASKSET mono Timespinner.exe 2>&1 | tee $GAMEDIR/log.txt
pm_finish
$ESUDO umount "$monodir"
unset LD_LIBRARY_PATH

# Disable console
printf "\033c" >> /dev/tty1
printf "\033c" > /dev/tty0
