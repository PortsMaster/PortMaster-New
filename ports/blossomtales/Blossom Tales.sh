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

gameassembly="Blossom Tales.exe"
export GAMEDIR="/$directory/ports/blossomtales"
cd "$GAMEDIR/gamedata"

# Grab text output...
$ESUDO chmod 666 /dev/tty0
printf "\033c" > /dev/tty0
echo "Loading... Please Wait." > /dev/tty0

# Log the execution of the script, the script overwrites itself on each launch
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Setup mono
monodir="$HOME/mono"
monofile="$controlfolder/libs/mono-6.12.0.122-aarch64.squashfs"
$ESUDO mkdir -p "$monodir"
$ESUDO umount "$monofile" || true
$ESUDO mount "$monofile" "$monodir"

# Setup savedir
mkdir -p "$GAMEDIR/savedata"
bind_directories ~/.local/share/"Blossom Tales" "$GAMEDIR/savedata"

# Setup path and other environment variables
export MONO_PATH="$GAMEDIR/dlls":"$GAMEDIR/gamedata":"$GAMEDIR/monomod"
export LD_LIBRARY_PATH="$GAMEDIR/libs":"$monodir/lib":"$LD_LIBRARY_PATH"
export PATH="$monodir/bin":"$PATH"
export MONODIR="$monodir"

# Unpack the Enigma Virtual Box bundle, if that hasn't happened yet.
if [ ! -f "$GAMEDIR/gamedata/$gameassembly" ]; then
    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        export ESUDO
        export PATCHER_FILE="$GAMEDIR/tools/patchscript"
        export PATCHER_GAME="$(basename "${0%.*}")"
        export PATCHER_TIME="1 to 3 minutes"
        export controlfolder
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb)
    else
        echo "This port requires the latest version of PortMaster." > /dev/tty0
        sleep 5
        exit 1
    fi
fi

# Prefer the system/bundled libs over anything the game shipped with.
rm -f System*.dll mscorlib.dll FNA.dll Mono.*.dll

# Configure the renderpath
export FNA3D_FORCE_DRIVER=OpenGL
export FNA3D_OPENGL_FORCE_ES3=1
export FNA3D_OPENGL_FORCE_VBO_DISCARD=1

regen_checksum=no
sha1sum -c "$GAMEDIR/gamedata/ver_checksum" >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Checksum fail or unpatched binary found, patching game..." 2>&1 | tee /dev/tty0
    rm -f "$GAMEDIR/gamedata/patch_done"
fi

# MONOMODDED files not found, let's perform patching
if [[ ! -f "$GAMEDIR/gamedata/patch_done" ]]; then
    echo "Performing game patching..." 2>&1 | tee /dev/tty0 "$GAMEDIR/install_log.txt"

    # Configure MonoMod settings
    export MONOMOD_MODS="$GAMEDIR/patches"
    export MONOMOD_DEPDIRS="${MONO_PATH}":"$GAMEDIR/monomod"

    # Merges the patch in and writes MONOMODDED_"Blossom Tales".exe. No HookGen step: the
    # patch installs its IL hooks by reflection at runtime rather than binding to generated
    # MMHOOK events, so nothing here depends on the executable's name.
    mono "$GAMEDIR/monomod/MonoMod.exe" "$GAMEDIR/gamedata/$gameassembly" 2>&1 | tee -a /dev/tty0 "$GAMEDIR/install_log.txt"
    if [ $? -ne 0 ]; then
        echo "Failure performing first time setup, report this." 2>&1 | tee -a /dev/tty0 "$GAMEDIR/install_log.txt"
        exit 1
    fi

    # Mark step as done
     touch "$GAMEDIR/gamedata/patch_done"
    regen_checksum=yes
fi

# Regenerate sha1sum checks, so a game update or a new patch triggers a repatch
if [[ x${regen_checksum} == xyes ]]; then
    sha1sum "$GAMEDIR/gamedata/$gameassembly" > "$GAMEDIR/gamedata/ver_checksum"
    sha1sum "$GAMEDIR/patches/"*.dll >> "$GAMEDIR/gamedata/ver_checksum"
fi

$GPTOKEYB "mono" &
pm_platform_helper "mono"
$TASKSET mono --ffast-math -O=all "MONOMODDED_${gameassembly}"

# Cleanup any running gptokeyb instances, and any platform specific stuff.
pm_finish
