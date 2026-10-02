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

# Variables
GAMEDIR="/$directory/ports/cometstrikerdx"
cd "$GAMEDIR/gamedata"

# Setup log
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Ensure executable permissions
$ESUDO chmod +x "$GAMEDIR/tools/patchscript"

# Check if we need to patch the game
if [ ! -f install_completed ]; then
    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        export controlfolder
        export ESUDO
        export DEVICE_ARCH
        export GAMEDIR
        export PATCHER_FILE="$GAMEDIR/tools/patchscript"
        export PATCHER_GAME="CometStriker DX"
        export PATCHER_TIME="a short while..."
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb)
    else
        pm_message "This port requires the latest version of PortMaster."
    fi
fi

# Setup mono
monodir="$HOME/mono"
monofile="$controlfolder/libs/mono-6.12.0.122-aarch64.squashfs"
$ESUDO mkdir -p "$monodir"
$ESUDO umount "$monofile" || true
$ESUDO mount "$monofile" "$monodir"

# Setup savedir
bind_directories "$HOME/.local/share/CometStrikerDX" "$GAMEDIR/savedata"

# Remove all the dependencies in favour of system libs
rm -f System*.dll mscorlib.dll FNA.dll Mono.*.dll

# Setup path and other environment variables
export MONO_PATH="$GAMEDIR/dlls"
export LD_LIBRARY_PATH="$GAMEDIR/libs:/usr/config/emuelec/lib:/usr/lib:$LD_LIBRARY_PATH"
export PATH="$monodir/bin:$GAMEDIR/libs:$PATH"
export MONO_GC_PARAMS="major=marksweep-conc"

# CometSriker DX needs this due to hardcoded paths
export MONO_IOMAP=all

export FNA3D_FORCE_DRIVER=OpenGL
export FNA3D_OPENGL_FORCE_ES3=1
export FNA_SDL2_FORCE_BASE_PATH=0
export SDL_NO_SIGNAL_HANDLERS=1
export SDL_TOUCH_MOUSE_EVENTS=0   
export SDL_MOUSE_TOUCH_EVENTS=0  

isitarkos=$(grep "title=" /usr/share/plymouth/themes/text.plymouth)
if [[ $isitarkos == *"ArkOS"* ]]; then
  $ESUDO perfnorm
fi

$GPTOKEYB "mono" &
pm_platform_helper "$monodir/bin/mono"
$TASKSET mono CometStrikerDX.exe

# Cleanup any running gptokeyb instances, and any platform specific stuff.
pm_finish