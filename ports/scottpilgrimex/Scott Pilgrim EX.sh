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

source "$controlfolder/control.txt"
source "$controlfolder/tasksetter"

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

export ESUDO=$ESUDO
export gameassembly="Game.exe"
export gamedir="/$directory/ports/scottpilgrimex"
cd "$gamedir/gamedata" || exit 1
find "$gamedir/gamedata" -type f -name '.DS_Store' -exec rm -f {} \;

# Grab text output...
$ESUDO chmod 666 /dev/tty0
printf "\033c" > /dev/tty0
echo "Loading... Please Wait." > /dev/tty0

# Setup mono
monodir="$HOME/mono"
monofile="$controlfolder/libs/mono-6.12.0.122-aarch64.squashfs"
$ESUDO mkdir -p "$monodir"
$ESUDO umount "$monofile" || true
if ! $ESUDO mount "$monofile" "$monodir"; then
    echo "ERROR: Cannot mount Mono runtime: $monofile"
    exit 1
fi

# Setup savedir
mkdir -p "$gamedir/savedata"
bind_directories ~/.local/share/Tribute\ Games/ScottPilgrimEX "$gamedir/savedata"

# Remove all the dependencies in favour of system libs - e.g. the included 
rm -f System*.dll mscorlib.dll FNA.dll Mono.*.dll

# Setup path and other environment variables
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
	rm -f "${gamedir}/gamedata/.intro_done"
fi

if [[ ! -f "$gamedir/gamedata/.astc_done" ]] ||
   [[ ! -f "$gamedir/gamedata/.patch_done" ]] ||
   [[ ! -f "$gamedir/gamedata/.intro_done" ]]; then
    echo "First-launch setup requested. Log: $gamedir/repack.log"
    chmod +x ../progressor ../repack.src ../utils/* ../patches/setup-screen ../patches/select-build
    if [ -f "$controlfolder/utils/patcher.txt" ] &&
       [ -f "$controlfolder/runtimes/love_11.5/love.txt" ] &&
       [ -x "$controlfolder/runtimes/love_11.5/love.$DEVICE_ARCH" ] &&
       [ -n "$GPTOKEYB" ] && declare -F pm_gptokeyb_finish >/dev/null; then
        echo "Setup display: PortMaster patcher"
        export PATCHER_FILE="bash \"$gamedir/patches/setup-screen\""
        export PATCHER_GAME="Scott Pilgrim EX"
        export PATCHER_TIME="a while; keep the device powered and awake"
        export PATCHER_QUESTIONS="$gamedir/utils/patcher-name.lua"
        export controlfolder
        rm -f "$gamedir/gamedata/.setup_screen_done"
        # Keep the patcher's runtime environment separate from the game.
        ( source "$controlfolder/utils/patcher.txt" )
        if [ ! -f "$gamedir/gamedata/.setup_screen_done" ]; then
            echo "Setup did not finish. See $gamedir/repack.log."
            exit 1
        fi
    else
        echo "PortMaster patch screen unavailable; using the setup log display."
        ../progressor --log "../repack.log" --font "../FiraCode-Regular.ttf" \
            --title "First Time Setup" ../repack.src
        [[ $? != 0 ]] && exit 1
    fi
    for marker in .patch_done .astc_done .intro_done; do
        [ -f "$gamedir/gamedata/$marker" ] || exit 1
    done
fi

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
