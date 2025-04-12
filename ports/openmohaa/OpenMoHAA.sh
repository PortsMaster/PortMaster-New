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

GAMEDIR=/$directory/ports/openmohaa
CONFDIR="$GAMEDIR/conf"
RUNDIR="$GAMEDIR/game"

cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

bind_directories ~/.openmohaa "$CONFDIR"

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"

export PATCHER_FILE="$GAMEDIR/tools/patchscript"
export PATCHER_TIME="5-10 minutes"

DIRS=`ls -d "$RUNDIR"/main* 2>/dev/null`
if [ -z "$DIRS" ]; then
  if [ -f "$controlfolder/utils/patcher.txt" ]; then
    $ESUDO chmod a+x "$GAMEDIR/tools/patchscript"
    source "$controlfolder/utils/patcher.txt"
    $ESUDO kill -9 $(pidof gptokeyb)
  else
    echo "This port requires the latest version of PortMaster." > $CUR_TTY
  fi
else
  echo Found "$DIRS"
  echo "Extraction process already completed. Skipping."
fi

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Run minilauncher
export LD_LIBRARY_PATH="$GAMEDIR/launcher/libs":$LD_LIBRARY_PATH
# Temporary fix for crossmix (disabled)
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"$controlfolder/runtimes/love_11.5/libs.aarch64":
chmod +x ./love
$GPTOKEYB "love" &
./love launcher

# see what they selected in the minilauncher
BINARY="$(cat selected_game.txt)"

# Cleanup launcher
rm -rf "selected_game.txt"
$ESUDO kill -9 $(pidof gptokeyb)
if [ -z "$BINARY" ]; then exit 1; fi

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [ "$LIBGL_FB" != "" ]; then
export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es.aarch64/libGL.so.1"
export SDL_VIDEO_EGL_DRIVER="$GAMEDIR/gl4es.aarch64/libEGL.so.1"
fi

# Use fullscreen mode on rocknix, otherwise the display is small
# On other CFWs, use windowed mode (otherwise crash on ArkOS)
if [ "$CFW_NAME" == ROCKNIX ] ; then
  FULLSCREEN=1
else
  FULLSCREEN=0
fi
sed -i -E "s/.*r_fullscreen.*/set r_fullscreen \"$FULLSCREEN\"/" \
  "$CONFDIR"/main*/configs/omconfig.cfg

# Scale screen to match device aspect ratio (640xY)
WIDTH=640
HEIGHT=$((WIDTH*ASPECT_Y/ASPECT_X))
sed -i -E "s/.*r_mode.*/set r_mode \"-1\"/" \
  "$CONFDIR"/main*/configs/omconfig.cfg
sed -i -E "s/.*r_customwidth.*/set r_customwidth \"$WIDTH\"/" \
  "$CONFDIR"/main*/configs/omconfig.cfg
sed -i -E "s/.*r_customheight.*/set r_customheight \"$HEIGHT\"/" \
  "$CONFDIR"/main*/configs/omconfig.cfg

# Calculate deadzone_scale based on DISPLAY_WIDTH
value=$((4*$WIDTH/480))
echo "Setting deadzone_scale to $value"
sed -i -E "s/(deadzone_scale) = .*/\1 = $value/g" \
  "$GAMEDIR/openmohaa.ini"

cd "$RUNDIR"

$GPTOKEYB2 "openmohaa.arm64" -c "$GAMEDIR/openmohaa.ini" &

pm_platform_helper "$RUNDIR/$BINARY" >/dev/null

./$BINARY

pm_finish
