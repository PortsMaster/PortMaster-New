#!/bin/bash
# PORTMASTER: lba2.zip, Little Big Adventure 2.sh

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

GAMEDIR="/$directory/ports/lba2"
BINARY="lba2cc.${DEVICE_ARCH}"

cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [ ! -f "$GAMEDIR/gamedata/LBA2.HQR" ] && [ ! -f "$GAMEDIR/gamedata/lba2.hqr" ]; then
  pm_show_error "Copy the data files from your GOG copy of Little Big Adventure 2 Classic to ports/lba2/gamedata/." --title "Game files missing" --type warning
  exit 1
fi

$ESUDO chmod +x "$GAMEDIR/$BINARY"

# Bind SDL's save path to the port's savedata folder.
mkdir -p "$GAMEDIR/savedata"
bind_directories "$XDG_DATA_HOME/Twinsen/LBA2" "$GAMEDIR/savedata"

# Seed the pad remap once; after that the file is the player's.
[ -f "$GAMEDIR/savedata/lba2.cfg" ] || cp "$GAMEDIR/conf/lba2.cfg" "$GAMEDIR/savedata/lba2.cfg"

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LBA2_GAME_DIR="$GAMEDIR/gamedata"

# Route CFW drivers through the SDL2 shim for the game only.
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

$GPTOKEYB2 "$BINARY" > /dev/null 2>&1 &

pm_platform_helper "$GAMEDIR/$BINARY"

SDL_VIDEODRIVER="$GAME_SDL_VIDEODRIVER" SDL_AUDIODRIVER="$GAME_SDL_AUDIODRIVER" "$GAMEDIR/$BINARY"

pm_finish
