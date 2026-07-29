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
GAMEDIR="/$directory/ports/roguelegacy"
cd "$GAMEDIR/gamedata"

# Setup log
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Sanity check: make sure the Content folder has actually been dropped in
if [ ! -d "$GAMEDIR/gamedata/Content" ]; then
    pm_message "Content folder missing! Copy your legally-owned Content/ folder into $GAMEDIR/gamedata/ and try again."
    sleep 5
    exit 1
fi

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

# Setup savedir - confirmed via testing: saves at ~/.local/share/RogueLegacy
bind_directories "$HOME/.local/share/RogueLegacy" "$GAMEDIR/savedata"

# Setup path and other environment variables
export MONO_PATH="$GAMEDIR/gamedata"
export LD_LIBRARY_PATH="$GAMEDIR/libs:/usr/config/emuelec/lib:/usr/lib:$LD_LIBRARY_PATH"
export PATH="$monodir/bin:$GAMEDIR/libs:$PATH"
export MONO_GC_PARAMS="major=marksweep,nursery-size=32m"
export MONO_IOMAP=all
export FNA_PLATFORM_BACKEND=SDL2
export SteamDeck=1

# FNA/GPU driver workarounds
export FNA3D_FORCE_DRIVER=OpenGL
export FNA3D_OPENGL_FORCE_ES3=1
export FNA3D_OPENGL_FORCE_VBO_DISCARD=1
export FNA_SDL2_FORCE_BASE_PATH=0
export SDL_NO_SIGNAL_HANDLERS=1
export SDL_TOUCH_MOUSE_EVENTS=0
export SDL_MOUSE_TOUCH_EVENTS=0

isitarkos=$(grep "title=" /usr/share/plymouth/themes/text.plymouth 2>/dev/null)
if [[ $isitarkos == *"ArkOS"* ]]; then
  $ESUDO perfnorm
fi

# Run the game
$GPTOKEYB "mono" &
pm_platform_helper "$monodir/bin/mono"
$TASKSET mono RogueLegacy.exe

# Cleanup
pm_finish
