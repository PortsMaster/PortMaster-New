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

GAMEDIR="/$directory/ports/sm64coopdx"
CONFDIR="$GAMEDIR/conf"
ARGS="--fullscreen"

mkdir -p "$CONFDIR"
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x "$GAMEDIR/sm64coopdx.${DEVICE_ARCH}"

bind_directories ~/.local/share/sm64coopdx "$CONFDIR"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

install() {
  if [ ! -f "$GAMEDIR/baserom.us.z64" ]; then
    romfile="$(find "$GAMEDIR" -maxdepth 1 -type f -iname "*.z64" | head -n 1)"
    if [ -n "$romfile" ]; then
      mv "$romfile" "$GAMEDIR/baserom.us.z64" || return 1
    else
      pm_message "Missing ROM, see README for more info."
      sleep 5
      return 1
    fi
  fi
}

if [ ! -f "$GAMEDIR/.installed" ]; then
  install && touch "$GAMEDIR/.installed" || exit 1
fi

$GPTOKEYB "sm64coopdx.${DEVICE_ARCH}" &
pm_platform_helper "$GAMEDIR/sm64coopdx.${DEVICE_ARCH}"
./sm64coopdx.${DEVICE_ARCH} $ARGS

pm_finish
