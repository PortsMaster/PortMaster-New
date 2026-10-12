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

GAMEDIR=/$directory/ports/ittledew
CONFDIR="$GAMEDIR/conf/"
BINARY=IttleDew.x86_64

cd $GAMEDIR

# First-run setup (tools/patchscript)
if [ ! -f "$GAMEDIR/gamedata/.patched_complete" ]; then
  if [ -f "$controlfolder/utils/patcher.txt" ]; then
    $ESUDO chmod +x "$GAMEDIR/tools/patchscript"
    export GAMEDIR controlfolder DEVICE_ARCH DISPLAY_WIDTH DISPLAY_HEIGHT
    export PATCHER_FILE="$GAMEDIR/tools/patchscript"
    export PATCHER_GAME="Ittle Dew"
    export PATCHER_TIME="up to 10 minutes"
    source "$controlfolder/utils/patcher.txt"
    $ESUDO kill -9 $(pidof gptokeyb)
  else
    pm_message "This port requires the latest version of PortMaster."
  fi
  [ -f "$GAMEDIR/gamedata/.patched_complete" ] || exit 1
fi

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd "$GAMEDIR/gamedata"
chmod +x "$GAMEDIR/box64" $BINARY

# virtual Xbox 360 pad: the game reads it as its own controller
$GPTOKEYB2 "IttleDew" -x &
pm_platform_helper "$GAMEDIR/box64"

# mipmaps for the few textures without their own (full-size installs)
[ -f "$GAMEDIR/gamedata/.shrink_done" ] || MIPMAPS="LIBGL_MIPMAP=1"

# the game is 16:9: it gets the largest 16:9 area that fits, shown centred
GW=$DISPLAY_WIDTH; GH=$((GW * 9 / 16)); [ $GH -gt $DISPLAY_HEIGHT ] && GH=$DISPLAY_HEIGHT && GW=$((GH * 16 / 9))

# gl4es + glxsdl (GLX on the firmware's SDL2) preloaded, X11 stand-ins in libs.aarch64; DISPLAY_* passed because
# sudo drops them on dArkOS; MONO_DISABLE_SHM: H700 kernels have no System V semaphores
$ESUDO env LD_LIBRARY_PATH="$GAMEDIR/libs.aarch64" LD_PRELOAD="$GAMEDIR/gl4es.aarch64/libGL.so.1:$GAMEDIR/libs.aarch64/libglxsdl.so" \
HOME=$CONFDIR DISPLAY_WIDTH=$DISPLAY_WIDTH DISPLAY_HEIGHT=$DISPLAY_HEIGHT XSTUB_SCREEN=${GW}x$GH GLXSDL_CONFIG="$GAMEDIR/glxsdl.ini" LIBGL_AVOID16BITS=0 LIBGL_NOBGRA=1 $MIPMAPS MONO_DISABLE_SHM=1 BOX64_LD_LIBRARY_PATH="$GAMEDIR/libs.x64" \
BOX64_DYNAREC_STRONGMEM=0 BOX64_DYNAREC_BIGBLOCK=3 BOX64_DYNAREC_FORWARD=1024 BOX64_DYNAREC_SAFEFLAGS=0 \
"$GAMEDIR/box64" ./$BINARY -screen-fullscreen 1 -screen-width $GW -screen-height $GH -logFile "$GAMEDIR/unity.log"

pm_finish
