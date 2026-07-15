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

GAMEDIR="/${directory#/}/ports/bully"
CONFIG="$GAMEDIR/bully.conf"

cd "$GAMEDIR" || exit 1
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

[ -f "$CONFIG" ] || cp "$GAMEDIR/bully.conf.default" "$CONFIG"

renderer=auto
render_scale=auto
textures=auto
trilinear=auto
stream_distance=auto
face_buttons=auto
shadows=off
use_gptk=off
source "$CONFIG"

export BULLY2_CONFIG_FILE="$CONFIG"
export BULLY2_TEXTURE_PROFILE="$textures"
export BULLY2_FACE_BUTTONS="$face_buttons"

# The ES2 renderer has no deferred-shadow path.
shadow_renderer=$renderer
if [ "$shadow_renderer" = auto ]; then
  read -r _ mem_kb _ < /proc/meminfo
  [ "${mem_kb:-0}" -ge 1740800 ] && shadow_renderer=es3 || shadow_renderer=es2
fi
[ "$shadow_renderer" = es3 ] || shadows=off
export BULLY2_SHADOWS="$shadows"
export BULLY2_SHADOW_DEFAULT="$shadows"
export BULLY2_SHADOWS_MAX=1
export BULLY2_WEAPON_SWITCH=native

[ "$renderer" = auto ] || export BULLY2_RENDERER="$renderer"
[ "$render_scale" = auto ] || export BULLY2_RENDER_SCALE="$render_scale"
[ "$trilinear" = auto ] || export BULLY2_TRILINEAR="$trilinear"
[ "$stream_distance" = auto ] || export BULLY2_STREAM_DISTANCE_PCT="$stream_distance"

export LD_LIBRARY_PATH="/usr/local/lib/aarch64-linux-gnu:/usr/local/lib/arm-linux-gnueabihf:/usr/lib:$GAMEDIR:$controlfolder/libs:${LD_LIBRARY_PATH:-}:/usr/lib/aarch64-linux-gnu:/lib/aarch64-linux-gnu"

if ! "$GAMEDIR/setup.sh"; then
  pm_message "Bully 1.4.311 game data was not found. Copy your complete legal ARM64 APK or APK bundle to ports/bully/gamedata."
  sleep 5
  exit 1
fi

if [ -z "${XDG_RUNTIME_DIR:-}" ] || [ ! -d "$XDG_RUNTIME_DIR" ]; then
  for runtime_dir in /run/0-runtime-dir "/run/user/$(id -u)" /run/user/0 /var/run/user/0 /tmp/bully-runtime; do
    [ -d "$runtime_dir" ] || [ "$runtime_dir" = /tmp/bully-runtime ] || continue
    mkdir -p "$runtime_dir"
    chmod 700 "$runtime_dir"
    export XDG_RUNTIME_DIR=$runtime_dir
    break
  done
fi

if [ -z "${WAYLAND_DISPLAY:-}" ]; then
  for socket in "$XDG_RUNTIME_DIR"/wayland-*; do
    [ -S "$socket" ] && export WAYLAND_DISPLAY=${socket##*/} && break
  done
fi

[ -n "${sdl_controllerconfig:-}" ] && export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export SDL2COMPAT_FORCE_FULLSCREEN_DESKTOP=1
export SDL_VIDEO_FULLSCREEN_DESKTOP=1
export MALLOC_ARENA_MAX=2
export MALLOC_TRIM_THRESHOLD_=131072
export MALLOC_MMAP_THRESHOLD_=65536
export ALSOFT_CONF="$GAMEDIR/alsoft.conf"

if [ "$use_gptk" = on ] && [ -n "${GPTOKEYB:-}" ]; then
  export BULLY2_INPUT=gptk
  export BULLY2_GPTK_DIRECT=1
  $GPTOKEYB "bully" -c "$GAMEDIR/bully.gptk" &
else
  unset BULLY2_INPUT BULLY2_GPTK_DIRECT
fi

pm_platform_helper "$GAMEDIR/bully"
"$GAMEDIR/bully"
command -v pm_finish >/dev/null 2>&1 && pm_finish
