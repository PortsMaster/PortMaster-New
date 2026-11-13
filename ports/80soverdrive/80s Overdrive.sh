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
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/80soverdrive"
cd "$GAMEDIR" || exit 1

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [ ! -f "$GAMEDIR/install_completed" ]; then
  if [ ! -f "$controlfolder/utils/patcher.txt" ]; then
    pm_show_error "This port needs the latest PortMaster." --title "Update PortMaster"
    exit 1
  fi
  chmod +x "$GAMEDIR/patch/patchscript.bash"
  export controlfolder ESUDO DEVICE_ARCH GAMEDIR
  export PATCHER_FILE="$GAMEDIR/patch/patchscript.bash"
  export PATCHER_GAME="80's Overdrive"
  export PATCHER_TIME="about a minute"
  source "$controlfolder/utils/patcher.txt"
fi

if [ ! -f "$GAMEDIR/install_completed" ]; then
  pm_show_error "Patching failed. Check ports/80soverdrive/patchlog.txt." --title "80's Overdrive"
  exit 1
fi

if [ ! -f "$GAMEDIR/gamedata/80s_Overdrive.exe" ]; then
  pm_show_error "Missing 80s_Overdrive.exe in gamedata." --title "80's Overdrive"
  exit 1
fi

monodir="$HOME/mono"
mono_runtime="mono-6.12.0.122-aarch64"
monofile="$controlfolder/libs/${mono_runtime}.squashfs"

if [ ! -f "$monofile" ]; then
  $ESUDO "$controlfolder/harbourmaster" --quiet --no-check runtime_check "${mono_runtime}.squashfs"
fi
if [ ! -f "$monofile" ]; then
  pm_show_error "Unable to find the Mono runtime." --title "80's Overdrive"
  exit 1
fi

$ESUDO mkdir -p "$monodir"
$ESUDO umount "$monofile" 2>/dev/null || true
if ! $ESUDO mount "$monofile" "$monodir"; then
  pm_show_error "Unable to mount the Mono runtime." --title "80's Overdrive"
  exit 1
fi

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

gl4esdir="$GAMEDIR/gl4es.${DEVICE_ARCH}"
[ -d "$gl4esdir" ] || gl4esdir="$GAMEDIR/gl4es"
if [[ ":$LD_LIBRARY_PATH:" == *":$gl4esdir:"* ]]; then
  export SDL_VIDEO_GL_DRIVER="$gl4esdir/libGL.so.1"
  export SDL_VIDEO_EGL_DRIVER="$gl4esdir/libEGL.so.1"
fi

libsdir="$GAMEDIR/libs.${DEVICE_ARCH}"
[ -d "$libsdir" ] || libsdir="$GAMEDIR/libs"

export PATH="$monodir/bin:$PATH"
export LD_LIBRARY_PATH="$libsdir:$monodir/lib:$LD_LIBRARY_PATH"
export MONO_PATH="$GAMEDIR/gamedata"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

cd "$GAMEDIR/gamedata" || exit 1

$GPTOKEYB2 "mono" > /dev/null 2>&1 &
pm_platform_helper "$monodir/bin/mono"
"$monodir/bin/mono" 80s_Overdrive.exe
result=$?

$ESUDO umount "$monodir"
pm_finish
exit "$result"
