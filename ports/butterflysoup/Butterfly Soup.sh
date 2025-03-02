#!/bin/bash
# PORTMASTER: butterflysoup.zip, Butterfly Soup.sh

# Prelude
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

# Variables 
PORTEXEC="renpy/startRENPY"
GAMEDIR="/$directory/ports/butterflysoup"
RUNTIME="renpy_8.1.3"
RENPYDIR="$GAMEDIR/renpy/"
GAMEFILES="$GAMEDIR/gamefiles/"
RENPY_RUNTIME="$controlfolder/libs/${RUNTIME}.squashfs"

cd "$GAMEDIR"

if [ ! -f "$controlfolder/libs/${RUNTIME}.squashfs" ]; then
  # Check for runtime if not downloaded via PM
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi

  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${RUNTIME}.squashfs"
fi

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1


$ESUDO mkdir -p "$RENPYDIR"

# Mounting Renpy and gamefiles
$ESUDO umount "$RENPYDIR/game" || true
$ESUDO umount "$RENPYDIR" || true
$ESUDO mount  "$RENPY_RUNTIME" "$RENPYDIR"
sleep 2
$ESUDO mount --bind "$GAMEFILES" "$RENPYDIR/game"

# Apply Patches
if [ ! -e "$GAMEDIR/patched" ]; then
  cp "$GAMEDIR/patches/overrides.rpy" "$GAMEFILES/"
  touch "$GAMEDIR/patched"
fi

# Exports
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export PYTHONHOME="$GAMEDIR/renpy"
export PYTHONPATH="$GAMEDIR/renpy/lib/python3.9"

# If using gl4es
if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [[ "$LIBGL_FB" != "" ]]; then
  export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es.$DEVICE_ARCH/libGL.so.1"
  export SDL_VIDEO_EGL_DRIVER="$GAMEDIR/gl4es.$DEVICE_ARCH/libEGL.so.1"
fi

pm_platform_helper "$GAMEDIR/renpy/lib/py3-linux-aarch64/startRENPY"
$GPTOKEYB2 "startRENPY" -c "butterflysoup.gptk"  &
bash "./$PORTEXEC"
pm_finish
