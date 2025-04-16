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

# Variables
PORTEXEC="renpy/startRENPY"
GAMEDIR="/$directory/ports/justkissheralready"

cd $GAMEDIR

runtime="renpy_8.3.4"
if [ ! -f "$controlfolder/libs/${runtime}.squashfs" ]; then
  # Check for runtime if not downloaded via PM
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi

  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${runtime}.squashfs"
fi

# Savedata setup
mkdir -p $GAMEDIR/conf
export XDG_DATA_HOME="$GAMEDIR/conf"
bind_directories ~/.renpy/ $GAMEDIR/conf/

renpydir="$GAMEDIR/renpy/"
$ESUDO mkdir -p "$renpydir"
renpy_runtime="$controlfolder/libs/${runtime}.squashfs"

# Mounting Renpy and gamefiles
$ESUDO umount "$renpy_runtime" || true
$ESUDO mount "$renpy_runtime" "$renpydir"
# Exports
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
export PYTHONHOME=$GAMEDIR/renpy/
export PYTHONPATH=$GAMEDIR/renpy/lib/python3.9

# If using gl4es
if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [[ "$LIBGL_FB" != "" ]]; then
  export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es/libGL.so.1"
  export SDL_VIDEO_EGL_DRIVER="$GAMEDIR/gl4es/libEGL.so.1"
fi

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

pm_platform_helper "$GAMEDIR/renpy/lib/py3-linux-aarch64/startRENPY"
$GPTOKEYB "startRENPY" -c "kissher.gptk" &
./$PORTEXEC $GAMEDIR/game

if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "$renpydir"
fi

pm_finish
