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
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR=/$directory/ports/jumpking
GAMEDATA="$GAMEDIR/gamedata"
cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Mono runtime, mounted before setup because setup patches the exe with the same runtime
monodir="$HOME/mono"
monofile="$controlfolder/libs/mono-6.12.0.122-aarch64.squashfs"
if [ ! -f "$monofile" ]; then
  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "mono-6.12.0.122-aarch64.squashfs"
fi
$ESUDO mkdir -p "$monodir"
$ESUDO umount "$monofile" || true
$ESUDO mount "$monofile" "$monodir"
export PATH="$monodir/bin:$PATH"
export MONODIR="$monodir" # tells the setup script which runtime to patch the exe with

# Setup patches the exe as its last step: no MonoMod marker in it means setup is needed (first launch, or fresh game files)
if ! grep -aqs MonoModAdded "$GAMEDATA/JumpKing.exe"; then
  export PATCHER_FILE="$GAMEDIR/tools/patch.bash"
  export PATCHER_GAME="Jump King"
  export PATCHER_TIME="5-10 mins"
  chmod +x "$PATCHER_FILE"
  source "$controlfolder/utils/patcher.txt"
  cd $GAMEDIR
  if ! grep -aqs MonoModAdded "$GAMEDATA/JumpKing.exe"; then
    pm_message "Jump King is not set up yet: copy your DRM-free GOG Jump King 1.06 game files into ports/jumpking/gamedata and launch again (log: patchlog.txt)."
    sleep 5
    pm_finish
    exit 1
  fi
fi

export LD_LIBRARY_PATH="$monodir/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi
if [[ ":$LD_LIBRARY_PATH:" == *":$GAMEDIR/gl4es.${DEVICE_ARCH}:"* ]]; then
  export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es.${DEVICE_ARCH}/libGL.so.1"
  export SDL_VIDEO_EGL_DRIVER="$GAMEDIR/gl4es.${DEVICE_ARCH}/libEGL.so.1"
fi

cd "$GAMEDATA"
$GPTOKEYB2 "mono" -c "$GAMEDIR/jumpking.ini" &
pm_platform_helper "$monodir/bin/mono"
mono --optimize=all JumpKing.exe

$ESUDO umount "$monodir"
pm_finish
