#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
if [ -d /opt/system/Tools/PortMaster ]; then
  controlfolder=/opt/system/Tools/PortMaster
elif [ -d /opt/tools/PortMaster ]; then
  controlfolder=/opt/tools/PortMaster
elif [ -d "$XDG_DATA_HOME/PortMaster" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder=/roms/ports/PortMaster
fi
source "$controlfolder/control.txt"
source "$controlfolder/tasksetter"
[ -f "$controlfolder/mod_${CFW_NAME}.txt" ] && source "$controlfolder/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/jetboardjoust"
cd "$GAMEDIR/gamedata"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Make patchscript executable
chmod +x "$GAMEDIR/patch/patchscript.bash"

# First-run patching
if [ ! -f install_completed ]; then
    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        export controlfolder
        export ESUDO
        export DEVICE_ARCH
        export GAMEDIR
        export PATCHER_FILE="$GAMEDIR/patch/patchscript.bash"
        export PATCHER_GAME="Jetboard Joust"
        export PATCHER_TIME="a short while..."
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb) 2>/dev/null
    else
        pm_message "This port requires the latest version of PortMaster."
    fi
fi

#.NET Core 3.1 runtime (PortMaster libs/dotnet-3.1.32.squashfs)
netdir="$HOME/dotnet3"
netfile="$controlfolder/libs/dotnet-3.1.32.squashfs"
mkdir -p "$netdir"
$ESUDO umount "$netdir" 2>/dev/null
if ! $ESUDO mount "$netfile" "$netdir"; then
  echo "ERROR: Cannot mount runtime: $netfile"
  pm_finish
  exit 1
fi
if [ ! -x "$netdir/dotnet" ]; then
  echo "ERROR: dotnet not found at $netdir/dotnet"
  $ESUDO umount "$netdir"
  pm_finish
  exit 1
fi
export DOTNET_ROOT="$netdir"
export DOTNET_ROOT_ARM64="$netdir"
export LD_LIBRARY_PATH="$netdir:$GAMEDIR/libs:/usr/config/emuelec/lib:/usr/lib:$LD_LIBRARY_PATH"
export PATH="$netdir:$PATH"
export SDL_NO_SIGNAL_HANDLERS=1
export SDL_TOUCH_MOUSE_EVENTS=0
export SDL_MOUSE_TOUCH_EVENTS=0

# Graphics: MonoGame needs desktop OpenGL, provided by the bundled gl4es
if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
elif [ -f "${controlfolder}/libgl_default.txt" ]; then
  source "${controlfolder}/libgl_default.txt"
fi
# Detect the Panfrost (Mesa) GPU driver: there the real-EGL/Mali-blob override must NOT be used.
jbj_is_panfrost() {
  local d t
  for d in /sys/class/drm/card*/device/driver /sys/class/drm/renderD*/device/driver; do
    [ -L "$d" ] || continue
    t="$(readlink "$d" 2>/dev/null)"
    case "$t" in *panfrost*) return 0 ;; esac
  done
  [ -d /sys/module/panfrost ] && return 0
  grep -qs '^panfrost ' /proc/modules && return 0
  return 1
}

JBJ_IS_PANFROST=0
jbj_is_panfrost && JBJ_IS_PANFROST=1

unset LIBGL_EGL LIBGL_GLES
# On Panfrost, Mesa already provides native OpenGL, so gl4es is not needed.
# JBJ_PANFROST_GL: native (default) = use Mesa's OpenGL directly; gl4es = force gl4es (GLES2 mode) on Panfrost
JBJ_PANFROST_GL="${JBJ_PANFROST_GL:-native}"
if [ "$JBJ_IS_PANFROST" = "1" ] && [ "$JBJ_PANFROST_GL" = "native" ]; then
  echo "Panfrost: using native Mesa OpenGL (gl4es not used)"
  unset SDL_VIDEO_GL_DRIVER SDL_VIDEO_EGL_DRIVER
  export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
else
  if [ "$JBJ_IS_PANFROST" = "1" ]; then
    # libgl_*.txt skips its gl4es settings when native GL exists; set them here for the forced-gl4es case
    export LIBGL_ES=2
    export LIBGL_GL=21
    unset LIBGL_FB
  fi
  export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es/libGL.so.1"
  export SDL_VIDEO_EGL_DRIVER="$GAMEDIR/gl4es/libEGL.so.1"
  export LD_LIBRARY_PATH="$GAMEDIR/gl4es:$GAMEDIR/libs:$LD_LIBRARY_PATH"
fi

# Save data
bind_directories "$HOME/.local/share/com.bitbull.jbj" "$GAMEDIR/savedata"

# Real EGL/GLES detection (all firmware). gl4es must be told where the REAL EGL/GLES live when the system
# libEGL.so.1 is a libglvnd dispatcher routing to Mesa (cannot drive the Mali GBM device, e.g. dArkOS and some
# Knulli builds). The Mali blob itself is used: it must export eglInitialize + glGetString and must not be a
# glvnd dispatcher. If nothing suitable is found nothing is overridden and gl4es keeps its defaults.
# JBJ_REAL_EGL=0 forces skip, 1 forces run; unset = auto (skipped when the Panfrost driver is in use).
# JBJ_REAL_EGL: unset = auto (skip on Panfrost), 0 = never run the override, 1 = always run it
JBJ_DO_REAL_EGL=1
if [ -n "${JBJ_REAL_EGL:-}" ]; then
  [ "$JBJ_REAL_EGL" = "0" ] && JBJ_DO_REAL_EGL=0
elif [ "$JBJ_IS_PANFROST" = "1" ]; then
  JBJ_DO_REAL_EGL=0
  echo "Panfrost GPU driver detected: skipping real EGL/GLES override (gl4es defaults)"
fi

if [ "$JBJ_DO_REAL_EGL" = "1" ]; then
  jbj_exports()  { [ -e "$1" ] && grep -q -a "eglInitialize" "$1" 2>/dev/null && grep -q -a "glGetString" "$1" 2>/dev/null; }
  jbj_is_glvnd() { grep -q -a "libGLdispatch" "$1" 2>/dev/null; }
  JBJ_EGL=""; JBJ_GLES=""
  # 1) a Mali blob that provides both EGL and GLES
  for f in /lib/aarch64-linux-gnu/libmali-*gbm*.so /usr/lib/aarch64-linux-gnu/libmali-*gbm*.so \
           /lib/aarch64-linux-gnu/libmali.so.1 /usr/lib/aarch64-linux-gnu/libmali.so.1 \
           /usr/lib/libmali.so.1 /lib/aarch64-linux-gnu/libmali.so; do
    if jbj_exports "$f" && ! jbj_is_glvnd "$f"; then JBJ_EGL="$f"; JBJ_GLES="$f"; break; fi
  done
  # 2) otherwise a plain (non-glvnd) system EGL / GLES
  if [ -z "$JBJ_EGL" ]; then
    for f in /usr/lib/aarch64-linux-gnu/libEGL.so.1 /lib/aarch64-linux-gnu/libEGL.so.1 /usr/lib/libEGL.so.1 /usr/lib64/libEGL.so.1; do
      if [ -e "$f" ] && ! jbj_is_glvnd "$f"; then JBJ_EGL="$f"; break; fi
    done
    for f in /usr/lib/aarch64-linux-gnu/libGLESv2.so.2 /lib/aarch64-linux-gnu/libGLESv2.so.2 /usr/lib/libGLESv2.so.2 /usr/lib64/libGLESv2.so.2; do
      if [ -e "$f" ] && ! jbj_is_glvnd "$f"; then JBJ_GLES="$f"; break; fi
    done
  fi
  [ -n "$JBJ_EGL" ]  && export LIBGL_EGL="$JBJ_EGL"
  [ -n "$JBJ_GLES" ] && export LIBGL_GLES="$JBJ_GLES"
  echo "Real EGL: ${JBJ_EGL:-none found (gl4es defaults)}  Real GLES: ${JBJ_GLES:-none found (gl4es defaults)}"
else
  echo "Real EGL/GLES override not used (gl4es defaults)"
fi

# Performance knobs read by the edited game DLL. 0 = off (original behaviour); unset / non-numeric = built-in reduced default.
export JJ_PARTICLE_PERCENT=50 # explosion particles emitted per frame, as % of original (original = 100, or 0 = off)
export JJ_CRACKLE_MAX=1       # max ExplosionCrackles drawn per frame (original = unlimited, 0 = off)
export JJ_GEOM_MAX_REPEATS=4  # max rings per GeometryShader draw (original 1-24+, 0 = off)
export JJ_GEOM_MAX_SHAPES=1   # max overlapping shapes per GeometryShader draw (original 1-4, 0 = off)
export JJ_STRIPE_MAX=3        # max flash-stripe repeats per explosion (original 5-7, 0 = off)
export JJ_IMPACT_GAP=4        # ground-impact ripple at most once per N frames (original every explosion, 0 = off)

# Game assembly: Steam build or GOG build (whichever this package ships)
if [ -f "$GAMEDIR/gamedata/JetboardJoust.Cpda.Steam.dll" ]; then
  GAMEDLL="JetboardJoust.Cpda.Steam.dll"
elif [ -f "$GAMEDIR/gamedata/JetboardJoust.Cpda.dll" ]; then
  GAMEDLL="JetboardJoust.Cpda.dll"
else
  echo "ERROR: no game assembly found in $GAMEDIR/gamedata"
  $ESUDO umount "$netdir"
  pm_finish
  exit 1
fi
echo "Game assembly: $GAMEDLL"

# Run the game
$GPTOKEYB "dotnet" &
pm_platform_helper "$netdir/dotnet"
$TASKSET "$netdir/dotnet" "$GAMEDIR/gamedata/$GAMEDLL"
echo "Game exit status: $?"

# Cleanup
$ESUDO umount "$netdir"
pm_finish
