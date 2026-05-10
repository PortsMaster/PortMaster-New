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

# pm
source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# variables
GAMEDIR="/$directory/ports/puzzlescriptpm"
CONFDIR="$GAMEDIR/conf/"

# cd & permissions
cd "$GAMEDIR"

# extract node binary on first run
if [ ! -f "$GAMEDIR/node" ]; then
  pm_message "Extracting node binary ..."
  if "$controlfolder/7zzs.$DEVICE_ARCH" x "$GAMEDIR/node.7z" -o"$GAMEDIR" -y; then
    pm_message "Extraction successful."
    chmod +x "$GAMEDIR/node"
    rm -f "$GAMEDIR/node.7z"
  else
    pm_message "Extraction failed!"
    pm_finish
    exit 1
  fi
fi

# enable logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# suppress console text on framebuffer
printf "\033[?25l" > /dev/tty0 2>/dev/null
printf "\033[2J" > /dev/tty0 2>/dev/null
stty -echo < /dev/tty0 2>/dev/null

# run
if [[ "$CFW_NAME" = "ROCKNIX" ]]; then
  # pipe through sdl2fb for display
  export SDL2FB=1
  export XDG_RUNTIME_DIR=/var/run/0-runtime-dir
  export WAYLAND_DISPLAY=wayland-1
  export SDL_VIDEODRIVER=wayland
  export SDL_APP_ID=sdl2fb
  chmod +x ./sdl2fb
  $GPTOKEYB "node" -c "./inputs.gptk" &
  pm_platform_helper "box64"
  ./node ./pruntime-node/main.js ./games/ | ./sdl2fb
else
  # direct framebuffer access (most firmware)
  $GPTOKEYB "node" -c "./inputs.gptk" &
  pm_platform_helper "node"
  ./node ./pruntime-node/main.js ./games/
fi

# restore console
stty echo < /dev/tty0 2>/dev/null
printf "\033[?25h" > /dev/tty0 2>/dev/null

# cleanup
pm_finish
