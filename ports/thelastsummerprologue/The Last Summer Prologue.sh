#!/bin/bash
# The Last Summer — PortMaster launch script (standard template, portmaster.games/packaging.html)
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

GAMEDIR=/$directory/ports/thelastsummerprologue
cd "$GAMEDIR"
# (An unzip that doesn't keep Unix permissions leaves the game not executable.)
$ESUDO chmod +x "$GAMEDIR/the-last-summer"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# The game's data ships as one archive (PortMaster reviews ports file by file): unpacked here on
# the first start, then removed.
ARCHIVE_FILE="gamedata.tar.gz"
if [[ -f "$ARCHIVE_FILE" ]]; then
  pm_message "Unpacking the game data (first start only)..."
  if gunzip -c "$ARCHIVE_FILE" | tar --no-same-owner -xf -; then
    pm_message "Done."
    $ESUDO rm -f "$ARCHIVE_FILE"
  else
    pm_message "Error: unpacking the game data failed."
    sleep 5
    exit 1
  fi
elif [[ ! -f "data/world.json" ]]; then
  pm_message "Error: no game data, and $ARCHIVE_FILE is missing."
  sleep 5
  exit 1
fi

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# The game reads SDL game controllers itself; gptokeyb only provides the exit hotkey.
$GPTOKEYB "the-last-summer" &
pm_platform_helper "$GAMEDIR/the-last-summer"
./the-last-summer --fullscreen
pm_finish
