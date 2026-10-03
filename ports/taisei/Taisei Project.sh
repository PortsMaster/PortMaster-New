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

GAMEDIR=/$directory/ports/taisei
BINARY=taisei.${DEVICE_ARCH}

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

ARCHIVE_FILES=(data-part*.tar.gz)
if [ -f "${ARCHIVE_FILES[0]}" ]; then
  if [ -d data/ ]; then
    pm_message "Removing old game data"
    $ESUDO rm -rf data/
  fi
  pm_message "Extracting game data, this can take a few minutes..."
  for archive in "${ARCHIVE_FILES[@]}"; do
    if ! gunzip -c "$archive" | tar xf -; then
      pm_message "Error: Extraction failed."
      sleep 5
      exit 1
    fi
  done
  pm_message "Extraction successful."
  $ESUDO rm -f "${ARCHIVE_FILES[@]}"
elif [ ! -d data/ ]; then
  pm_message "Error: No data directory present and archive files not found."
  sleep 5
  exit 1
fi

$ESUDO chmod +x "$GAMEDIR/$BINARY"

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TAISEI_STORAGE_PATH="$GAMEDIR/conf"
export TAISEI_CACHE_PATH="$GAMEDIR/cache"

# The default 512-frame audio buffer pops on slower devices; use 1024
if [ -f "$GAMEDIR/conf/config" ]; then
  sed -i 's/^mixer_chunksize = 512$/mixer_chunksize = 1024/' "$GAMEDIR/conf/config"
else
  mkdir -p "$GAMEDIR/conf"
  printf '@version = 4\nmixer_chunksize = 1024\n' > "$GAMEDIR/conf/config"
fi

GAME_SDL_VIDEODRIVER=""
if [ -n "$SDL_VIDEODRIVER" ]; then
  export SDL3SHIM_SDL2_VIDEODRIVER="$SDL_VIDEODRIVER"
  GAME_SDL_VIDEODRIVER=sdl2
fi

GAME_SDL_AUDIODRIVER=""
if [ -n "$SDL_AUDIODRIVER" ]; then
  export SDL3SHIM_SDL2_AUDIODRIVER="$SDL_AUDIODRIVER"
  GAME_SDL_AUDIODRIVER=sdl2
fi

$GPTOKEYB "$BINARY" &

pm_platform_helper "$GAMEDIR/$BINARY"

SDL_VIDEODRIVER="$GAME_SDL_VIDEODRIVER" SDL_AUDIODRIVER="$GAME_SDL_AUDIODRIVER" ./$BINARY

pm_finish
