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

GAMEDIR="/$directory/ports/rez"
BINARY="rez.${DEVICE_ARCH}"
cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

mkdir -p "$GAMEDIR/conf/rez_recompiled"
bind_directories ~/.config/rez_recompiled "$GAMEDIR/conf/rez_recompiled"
bind_directories ~/.local/share/rez_recompiled "$GAMEDIR/conf/rez_recompiled"

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

shopt -s nullglob nocaseglob
chd_files=("$GAMEDIR/gamedata/"*.chd "$GAMEDIR/"*.chd)
shopt -u nullglob nocaseglob
if [ ${#chd_files[@]} -eq 0 ]; then
  pm_show_error "Copy the .chd image from your Japanese (HDR-0178) or European (MK-5119250) Dreamcast Rez V1.003 disc to ports/rez/gamedata/ and launch again." --title "Game files missing"
  pm_finish
  exit 1
fi

if [ -f "$GAMEDIR/rez.patch" ] || [ ! -x "$GAMEDIR/$BINARY" ] || [ ! -f "$GAMEDIR/extracted/fs/1ST_READ.BIN" ]; then
  chmod +x "$GAMEDIR/tools/patchscript" "$GAMEDIR/tools/rez-patch" 2>/dev/null || true
  PATCHER_FILE="$GAMEDIR/tools/patchscript"
  PATCHER_GAME="$(basename "${0%.*}")"
  PATCHER_TIME="about 15 seconds"
  export PATCHER_FILE PATCHER_GAME PATCHER_TIME controlfolder ESUDO DEVICE_ARCH GAMEDIR BINARY
  if [ -f "$controlfolder/utils/patcher.txt" ]; then
    source "$controlfolder/utils/patcher.txt"
  else
    pm_show_error "This port requires the latest version of PortMaster." --title "Update required"
    pm_finish
    exit 1
  fi
  if [ ! -x "$GAMEDIR/$BINARY" ] || [ ! -f "$GAMEDIR/extracted/fs/1ST_READ.BIN" ]; then
    pm_finish
    exit 1
  fi
fi

$GPTOKEYB2 "$BINARY" > /dev/null 2>&1 &

pm_platform_helper "$GAMEDIR/$BINARY"

./$BINARY

pm_finish
