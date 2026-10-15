#!/bin/bash
# PORTMASTER: penumbra.zip, Penumbra Overture.sh

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

GAMEDIR=/$directory/ports/penumbra
BINARY=PenumbraOverture

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO chmod 666 /dev/uinput
chmod +x "$GAMEDIR/$BINARY"

# Only OpenAL is carried along; SDL2 and GLES come from the system.
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

# Settings and saves go to $HOME/.frictionalgames. This has to be the game folder
# itself: pointing it at a subfolder orphans the saves of anyone already playing.
export HOME="$GAMEDIR"

# A touchscreen reports where a finger is, not how far it moved, so as a mouse it
# plants the pointer at an absolute spot and the view stops turning.
if [ "$CFW_NAME" = "ROCKNIX" ]; then
  export SDL_TOUCH_MOUSE_EVENTS=0
  swaymsg input type:touch events disabled 2>/dev/null
fi

# Read by the engine. These sticks report no tilt, only on or off, so the pointer
# ramps up while held, and the view alone turns faster than the inventory cursor.
export HPL_MOUSE_ACCEL=3:2:1
export HPL_LOOK_SCALE=2

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$GPTOKEYB "$BINARY" -c "$GAMEDIR/penumbra.gptk" > /dev/null 2>&1 &

pm_platform_helper "$GAMEDIR/$BINARY"

# On ROCKNIX the frontend is a sway client and keeps the pointer focus, so every
# run after the first one gets no mouse events at all and the view will not turn.
# Skipped where there is no swaymsg.
if command -v swaymsg >/dev/null 2>&1; then
  (
    for dir in "$XDG_RUNTIME_DIR" /var/run/0-runtime-dir /run/user/0; do
      sock=$(ls "$dir"/sway-ipc*.sock 2>/dev/null | head -1)
      [ -n "$sock" ] && break
    done
    [ -n "$sock" ] || exit 0
    export SWAYSOCK="$sock"
    # The window takes a few seconds to appear, so keep asking for a while.
    for _ in 1 2 3 4 5 6 7 8; do
      sleep 2
      swaymsg '[app_id="PenumbraOverture"] focus' >/dev/null 2>&1
    done
  ) &
fi

"$GAMEDIR/$BINARY"

pm_finish
