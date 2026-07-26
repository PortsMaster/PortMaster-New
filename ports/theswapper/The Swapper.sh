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

GAMEDIR="/$directory/ports/theswapper"
GAMEDATA="$GAMEDIR/gamedata"
SAVEDIR="$GAMEDIR/savedata-home"
MONO_DIR="$HOME/mono"
MONO_FILE="$controlfolder/libs/mono-6.12.0.122-aarch64.squashfs"

mkdir -p "$GAMEDATA" "$SAVEDIR"
cd "$GAMEDIR" || exit 1

: >"$GAMEDIR/log.txt"
exec > >(tee "$GAMEDIR/log.txt") 2>&1

run_setup() {
  if [ ! -f "$controlfolder/utils/patcher.txt" ] || [ ! -x "$controlfolder/astcenc.aarch64" ]; then
    pm_message "This port requires the latest PortMaster release. Update PortMaster and try again."
    return 1
  fi

  chmod +x "$GAMEDIR/tools/setup" "$GAMEDIR/tools/texture-astc-manifest" \
    "$GAMEDIR/tools/texture-downscale" "$GAMEDIR/tools/xdg-open"

  export PATCHER_FILE="$GAMEDIR/tools/setup"
  export PATCHER_GAME="The Swapper"
  export PATCHER_TIME="a few minutes"
  export PATCHER_ASTC_ENCODER="$controlfolder/astcenc.aarch64"

  source "$controlfolder/utils/patcher.txt"
}

if [ ! -f "$GAMEDIR/.setup_complete" ]; then
  run_setup
fi

if [ ! -f "$GAMEDIR/.setup_complete" ]; then
  pm_message "Setup did not complete. Check ports/theswapper/setup.log."
  sleep 5
  exit 1
fi

$ESUDO mkdir -p "$MONO_DIR"
$ESUDO umount "$MONO_DIR" >/dev/null 2>&1 || true
$ESUDO mount "$MONO_FILE" "$MONO_DIR"

export HOME="$SAVEDIR"
export PATH="$GAMEDIR/tools:$MONO_DIR/bin:$PATH"
export BROWSER="$GAMEDIR/tools/xdg-open"
export MONO_PATH="$GAMEDATA"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export MONO_MANAGED_WATCHER=1
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:${LD_LIBRARY_PATH:-}"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [[ "${DEVICE_ARCH}" != "x86_64" && (-n "${LIBGL_FB:-}" || -n "${LIBGL_ES:-}") ]]; then
  export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es.${DEVICE_ARCH}/libGL.so.1"
  export SDL_VIDEO_EGL_DRIVER="$GAMEDIR/gl4es.${DEVICE_ARCH}/libEGL.so.1"
fi

ASTC_CACHE_DIR="$GAMEDIR/asset-patches/astc"
ASTC_MANIFEST="$ASTC_CACHE_DIR/manifest.tsv"
ASTC_LIB="$GAMEDIR/libs.${DEVICE_ARCH}/libtexture_astc.so"
if [ -f "$ASTC_MANIFEST" ] && [ -f "$ASTC_LIB" ]; then
  export SWAPPER_ASTC_CACHE_DIR="$ASTC_CACHE_DIR"
  export SWAPPER_ASTC_MANIFEST="$ASTC_MANIFEST"
  export LD_PRELOAD="$ASTC_LIB${LD_PRELOAD:+:$LD_PRELOAD}"
fi

cd "$GAMEDATA" || exit 1

$GPTOKEYB "mono" &
pm_platform_helper "$MONO_DIR/bin/mono"
$TASKSET mono TheSwapper.exe

$ESUDO umount "$MONO_DIR" >/dev/null 2>&1 || true
pm_finish
