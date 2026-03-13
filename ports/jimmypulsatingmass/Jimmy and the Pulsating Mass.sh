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

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/jimmypulsatingmass"
CONFDIR="$GAMEDIR/conf/"

CUR_TTY=/dev/tty0
$ESUDO chmod 666 $CUR_TTY

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd "$GAMEDIR"

# Check for game data
if [ ! -f "$GAMEDIR/gamedata/Game.rgss3a" ]; then
  echo "Error: Game.rgss3a not found in gamedata/."
  echo "Please copy game files from your Jimmy and the Pulsating Mass"
  echo "mkxp version into $GAMEDIR/gamedata/"
  sleep 5
  printf "\033c" > /dev/tty0
  exit 1
fi

# Ensure the conf directory exists
mkdir -p "$GAMEDIR/conf"

# Set the XDG environment variables for config & savefiles
export XDG_CONFIG_HOME="$CONFDIR"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

# Move binary into gamedata if needed, copy config
[ -f falcon_mkxp.bin ] && mv falcon_mkxp.bin gamedata/falcon_mkxp.bin
cp conf/mkxp.conf gamedata/

$GPTOKEYB "falcon_mkxp.bin" -c "$GAMEDIR/jimmypulsatingmass.gptk" &
pm_platform_helper "$GAMEDIR/gamedata/falcon_mkxp.bin"
"$GAMEDIR/gamedata/falcon_mkxp.bin"

pm_finish
