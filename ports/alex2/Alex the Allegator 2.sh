#!/bin/bash

# Captured before westonwrap.sh runs, which overrides XDG_RUNTIME_DIR to its
# own /tmp path for Weston's own Wayland socket. The system audio daemon
# (PipeWire/PulseAudio) needs the *real* XDG_RUNTIME_DIR to find its own
# socket, so this gets passed through explicitly to the game process only,
# below, without touching what Weston itself uses.
REAL_XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}

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

GAMEDIR=/$directory/ports/alex2
CONFDIR="$GAMEDIR/conf/"
BINARY=alex2.${DEVICE_ARCH}

mkdir -p "$GAMEDIR/conf"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export XDG_DATA_HOME="$CONFDIR"
export game_libs="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Alex the Allegator 2 is a plain Allegro 4 software-2D game (no OpenGL), which
# renders through Allegro's X11/Xlib driver on Linux - runs via Westonpack's
# "Xlib Games (No OpenGL)" mode, no GL4ES/crusty needed.
weston_dir=/tmp/weston
$ESUDO mkdir -p "${weston_dir}"
weston_runtime="weston_pkg_0.2"
if [ ! -f "$controlfolder/libs/${weston_runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi
  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${weston_runtime}.squashfs"
fi
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
fi
$ESUDO mount "$controlfolder/libs/${weston_runtime}.squashfs" "${weston_dir}"

# The game is entirely mouse-driven (menus, token placement, row/column
# slides) - the .gptk maps the left analog stick to mouse movement and A/B
# to left/right click. TEXTINPUTINTERACTIVE enables gptokeyb's built-in
# on-screen keyboard (Start + D-Pad Down) for typing a name into the high
# score table, which the game reads via raw keypresses.
export TEXTINPUTINTERACTIVE=Y
$GPTOKEYB "$BINARY" -c "./alex2.gptk" &
pm_platform_helper "$GAMEDIR/$BINARY"

$ESUDO env WRAPPED_LIBRARY_PATH=$game_libs \
$weston_dir/westonwrap.sh drm gl kiosk system \
ULTRADIR=$GAMEDIR XDG_DATA_HOME=$CONFDIR XDG_RUNTIME_DIR=$REAL_XDG_RUNTIME_DIR $GAMEDIR/$BINARY

$ESUDO $weston_dir/westonwrap.sh cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
fi
pm_finish
