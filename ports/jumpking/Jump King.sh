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
MARKER="$GAMEDATA/.jk_setup_done"

cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [ ! -f "$GAMEDATA/JumpKing.exe" ]; then
  pm_show_error "Copy your DRM-free GOG Jump King game files into ports/jumpking/gamedata and launch again." --title "Game files missing" --type warning
  exit 1
fi

if [ ! -d "$GAMEDATA/Content" ]; then
  pm_show_error "The Content folder is missing. Copy your DRM-free GOG Jump King game folder into ports/jumpking/gamedata and launch again." --title "Game files missing" --type warning
  exit 1
fi

# Mono has to be mounted before the patcher runs: it weaves the executable with
# the same runtime that launches the game.
monodir="$HOME/mono"
mono_runtime="mono-6.12.0.122-aarch64"
monofile="$controlfolder/libs/${mono_runtime}.squashfs"

if [ ! -f "$monofile" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_show_error "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info." --title "PortMaster update needed"
    exit 1
  fi
  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${mono_runtime}.squashfs"
fi

$ESUDO mkdir -p "$monodir"
$ESUDO umount "$monodir" 2>/dev/null || true
$ESUDO mount "$monofile" "$monodir"
BINARY="$monodir/bin/mono"
if [ ! -x "$BINARY" ]; then
  pm_show_error "Failed to mount the Mono runtime. Cannot continue." --title "Mono runtime missing" --type warning
  exit 1
fi

export MONODIR="$monodir"
export MONO="$BINARY"
export controlfolder
export ESUDO
export DEVICE_ARCH

# Setup is needed on the first launch, and again if the exe is no longer patched
# (for example the player copied fresh game files over it).
if [ -f "$MARKER" ] && ! grep -aq MonoModAdded "$GAMEDATA/JumpKing.exe"; then
  echo "JumpKing.exe is not patched - re-running setup."
  rm -f "$MARKER"
fi

if [ ! -f "$MARKER" ]; then
  chmod +x "$GAMEDIR/tools/patch.bash"
  export PATCHER_FILE="$GAMEDIR/tools/patch.bash"
  export PATCHER_GAME="Jump King"
  export PATCHER_TIME="5-10 mins"
  source "$controlfolder/utils/patcher.txt"

  if [ ! -f "$MARKER" ]; then
    pm_show_error "First-launch setup did not finish. See ports/jumpking/patchlog.txt, then launch again to retry." --title "Setup incomplete" --type warning
    $ESUDO umount "$monodir" 2>/dev/null
    exit 1
  fi
fi

cp -f "$GAMEDIR"/dlls/* "$GAMEDATA/"
cp -f "$GAMEDIR/tools/Mask.xnb" "$GAMEDATA/Content/shaders/"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"

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

$GPTOKEYB2 "mono" -c "$GAMEDIR/jumpking.ini" > /dev/null 2>&1 &

pm_platform_helper "$BINARY"

"$BINARY" --optimize=all JumpKing.exe

$ESUDO umount "$monodir"

pm_finish
