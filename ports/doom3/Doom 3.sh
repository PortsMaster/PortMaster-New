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
source $controlfolder/device_info.txt
get_controls

PORTS_DIR="/$directory/ports"
GAME_DIR="${PORTS_DIR}/doom3"
LOG_FILE="${GAME_DIR}/log.txt"
cd $GAME_DIR

# Decide which game to launch - demo / full / expansion pack.
# You are able to override by setting a value here as follows:
# - demo (Doom 3 demo version)
# - base (Doom 3 full version)
# - d3xp (Resurrection of Evil expansion pack)
GAME=

# If no override set, check which PK4 files exist
if [[ -z "${GAME}" ]]; then
  if [[ -f "${GAME_DIR}/d3xp/pak000.pk4" ]] &&
    [[ -f "${GAME_DIR}/d3xp/pak001.pk4" ]]; then
    GAME="d3xp"
  elif [[ -f "${GAME_DIR}/base/pak001.pk4" ]] &&
    [[ -f "${GAME_DIR}/base/pak002.pk4" ]] &&
    [[ -f "${GAME_DIR}/base/pak003.pk4" ]] &&
    [[ -f "${GAME_DIR}/base/pak004.pk4" ]] &&
    [[ -f "${GAME_DIR}/base/pak005.pk4" ]] &&
    [[ -f "${GAME_DIR}/base/pak006.pk4" ]] &&
    [[ -f "${GAME_DIR}/base/pak007.pk4" ]] &&
    [[ -f "${GAME_DIR}/base/pak008.pk4" ]]; then
    GAME="base"
  elif [[ -f "${GAME_DIR}/demo/demo00.pk4" ]]; then
    GAME="demo"
  fi
fi

exec > >(tee "$LOG_FILE") 2>&1

$ESUDO chmod 666 /dev/uinput

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$GPTOKEYB "dhewm3" -c "./dhewm3.gptk" &
./dhewm3 +set r_mode "-1" +set r_customWidth "$DISPLAY_WIDTH" +set r_customHeight "$DISPLAY_HEIGHT" +set fs_game "$GAME"

$ESUDO kill -9 $(pidof gptokeyb)
unset SDL_GAMECONTROLLERCONFIG
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0

