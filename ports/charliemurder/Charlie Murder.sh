#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "/userdata/roms/ports/PortMaster" ]; then
  controlfolder="/userdata/roms/ports/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/tasksetter
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

export gamedir="/$directory/ports/charliemurder"
export gameassembly="CharlieMurder.exe"
cd "$gamedir/gamedata"

echo "Cleaning macOS artifact files..."
find "$gamedir" -name "._*" -type f -delete 2>/dev/null
find "$gamedir" -name ".DS_Store" -type f -delete 2>/dev/null

# Sanity checks
if [ ! -f "$gamedir/gamedata/${gameassembly}" ]; then
    pm_message "What the... What have you done? There are no gamefiles in your port. How do you want to play without them? Come on! Pick your legal copy from Steam (depot 405290 405291) and start over again!"
    sleep 15
    exit 1
fi

if [ ! -f "$gamedir/gamedata/Content/sfx/music.xsb" ] || [ ! -f "$gamedir/gamedata/Content/sfx/music.xwb" ]; then
    pm_message "Whoops -- looks like you grabbed the wrong build of Charlie Murder. This port needs the Windows depot. Redownload with 'download_depot 405290 405291', copy those files in, and try again."
    sleep 15
    exit 1
fi

# Grab text output...
$ESUDO chmod 666 /dev/tty0
printf "\033c" > /dev/tty0
echo "Loitering... Please Wait." > /dev/tty0

export MONO_GC_PARAMS="nursery-size=128m,major=marksweep"
> "$gamedir/log.txt"
> "$gamedir/monomod_error.txt"
echo "RAM: $(free -m | awk 'NR==2{print $4}') MB frei" >> "$gamedir/log.txt"

export FNA3D_OPENGL_FORCE_ES3=1
export SDL_VIDEO_GL_DRIVER=libGLESv2.so

# Setup mono
monodir="$HOME/mono"
mono_runtime="mono-6.12.0.122-aarch64"
monofile="$controlfolder/libs/${mono_runtime}.squashfs"
if [ ! -f "$monofile" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the latest PortMaster to run. Please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi
  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${mono_runtime}.squashfs"
fi
$ESUDO mkdir -p "$monodir"
$ESUDO umount "$monofile" || true
$ESUDO mount "$monofile" "$monodir"

# Setup savedir
mkdir -p "$gamedir/savedata"
mkdir -p ~/.local/share ~/.config

# Control mapping
if [ ! -f "$gamedir/savedata/controls.ini" ]; then
    cp "$gamedir/patches/controls.ini" "$gamedir/savedata/controls.ini"
fi

$ESUDO rm -rf ~/.local/share/CharlieMurder
$ESUDO rm -f ~/.local/share/CharlieMurder
$ESUDO ln -sfn "$gamedir/savedata" ~/.local/share/CharlieMurder
$ESUDO rm -rf ~/.config/CharlieMurder
$ESUDO rm -f ~/.config/CharlieMurder
$ESUDO mkdir -p ~/.config/CharlieMurder
$ESUDO mount --bind "$gamedir/savedata" ~/.config/CharlieMurder

# Remove Windows-only DLLs in favour of system/port libs
rm -f System*.dll Mono.*.dll mscorlib.dll FNA.dll

# FIX: Copy dll configs to gamedata so mono finds them
cp "$gamedir/dlls/SDL2-CS.dll.config" "$gamedir/gamedata/"
cp "$gamedir/dlls/FNA.dll.config" "$gamedir/gamedata/"

# Setup path and other environment variables
export MONO_PATH="$gamedir/dlls"
export LD_LIBRARY_PATH="$gamedir/libs.aarch64":"$monodir/lib":/usr/config/emuelec/lib32:/usr/lib32:$LD_LIBRARY_PATH
export PATH="$monodir/bin":"$PATH"
echo "Active Mono: $(which mono) - Version: $(mono --version | head -1)" >> "$gamedir/log.txt"

# Force GLES3 and VBO Discard hack
export FNA3D_OPENGL_FORCE_VBO_DISCARD=1
export FNA_SDL2_FORCE_BASE_PATH=0
export MONO_GENERIC_SHARING=none

# Steam stub
echo "405290" > "$gamedir/gamedata/steam_appid.txt"
export SteamAppId=405290
export STEAMID=405290

# Do first time setup if either checksum fails or .astc_done isn't present
if sha1sum -c "${gamedir}/gamedata/.ver_checksum" > /dev/null 2>&1 && \
   [[ -f "${gamedir}/gamedata/.astc_done" ]] && [[ -f "${gamedir}/gamedata/.patch_done" ]]; then
    : # already patched, skip
else
        export PATCHER_FILE="$gamedir/patches/first_setup.bash"
    export PATCHER_GAME="Charlie Murder"
    export PATCHER_TIME="about 40 minutes"
    export PATCHER_QUESTIONS="$gamedir/patches/patcher_questions.lua"

    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        $ESUDO chmod a+x "$gamedir/patches/first_setup.bash"
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb2)
    else
        echo "This port requires the latest version of PortMaster."
        sleep 5
        exit 1
    fi

    if [[ ! -f "${gamedir}/gamedata/.astc_done" ]] || [[ ! -f "${gamedir}/gamedata/.patch_done" ]]; then
        echo "Patching failed"
        sleep 5
        exit -1
    fi
fi

# FIX: Install dmix asoundrc so ES and Charlie Murder can share ALSA simultaneously (dArkOS only!)
cfw_lower=$(echo "$CFW_NAME" | tr '[:upper:]' '[:lower:]')
echo "Detected CFW_NAME: '$CFW_NAME' (normalized: '$cfw_lower')" >> "$gamedir/log.txt"

CM_ASOUNDRC_APPLIED=0
case "$cfw_lower" in
    *darkos*)
        [ -f "$HOME/.asoundrc" ] && cp "$HOME/.asoundrc" "$HOME/.asoundrc.cm_bak"
        cp "$gamedir/asoundrc" "$HOME/.asoundrc"
        CM_ASOUNDRC_APPLIED=1
        echo "Applied custom asoundrc for dArkOS" >> "$gamedir/log.txt"
        ;;
    *)
        echo "Skipping custom asoundrc for CFW '$CFW_NAME' - using system default ALSA config" >> "$gamedir/log.txt"
        ;;
esac

# Run MonoMod to create MONOMODDED_CharlieMurder.exe (only if not already present)
cp "$gamedir/dlls/FNA.Steamworks.dll" "$gamedir/gamedata/FNA.Steamworks.dll"
if [ ! -f "$gamedir/gamedata/MONOMODDED_${gameassembly}" ]; then
    echo "Running MonoMod patcher..." >> "$gamedir/log.txt"
    # Copy patch dll to gamedata so MonoMod finds it alongside the assembly
    cp "$gamedir/patches/CharlieMurder.CharlieMurderPatches.mm.dll" "$gamedir/gamedata/"
    MONOMOD_DEPDIRS="${MONO_PATH}":"${gamedir}/monomod":"${gamedir}/dlls" \
    $TASKSET mono --ffast-math -O=all "$gamedir/monomod/MonoMod.exe" \
        "$gamedir/gamedata/${gameassembly}" >> "$gamedir/log.txt" 2>> "$gamedir/monomod_error.txt"
    echo "MonoMod exit code: $?" >> "$gamedir/log.txt"

    # Cleanup: remove patch dll from gamedata
    rm -f "$gamedir/gamedata/CharlieMurder.CharlieMurderPatches.mm.dll"
fi

$GPTOKEYB2 "mono" &
$TASKSET mono --ffast-math -O=all ../MMLoader.exe "MONOMODDED_${gameassembly}" >> "$gamedir/log.txt" 2>> "$gamedir/monomod_error.txt"
if [ -f ~/.local/share/CharlieMurder/crash.txt ]; then
    cp ~/.local/share/CharlieMurder/crash.txt "$gamedir/savedata/crash.txt"
fi
$ESUDO kill -9 $(pidof mono) 2>/dev/null || true
cat "$gamedir/monomod_error.txt" >> "$gamedir/log.txt"
$ESUDO kill -9 $(pidof gptokeyb2)

# Restore original ~/.asoundrc
if [ "$CM_ASOUNDRC_APPLIED" = "1" ]; then
    if [ -f "$HOME/.asoundrc.cm_bak" ]; then
        mv "$HOME/.asoundrc.cm_bak" "$HOME/.asoundrc"
    else
        rm -f "$HOME/.asoundrc"
    fi
fi

$ESUDO umount ~/.config/CharlieMurder 2>/dev/null || true
$ESUDO systemctl restart oga_events &
$ESUDO umount "$monodir"

# Disable console
printf "\033c" >> /dev/tty1