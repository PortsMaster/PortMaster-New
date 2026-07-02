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

GAMEDIR="/$directory/ports/gravitycircuit"
TOOLDIR=$GAMEDIR/tools
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

# extract, diff
GAMEFILE="./gamedata/GravityCircuit.exe"
if [ -f "$GAMEFILE" ]; then
  export PATCHER_FILE="$TOOLDIR/patchscript"
  export PATCHER_TIME="2-5 minutes"
  export controlfolder
  if [ -f "$controlfolder/utils/patcher.txt" ]; then
    $ESUDO chmod a+x "$TOOLDIR/patchscript"
    source "$controlfolder/utils/patcher.txt"
    pm_gptokeyb_finish
  else
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit
  fi
fi

export XDG_DATA_HOME="$GAMEDIR/conf" # allowing saving to the same path as the game
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
mkdir -p "$XDG_DATA_HOME"

cd $GAMEDIR
# Source love2d runtime
source $controlfolder/runtimes/"love_11.5"/love.txt

# Use the love runtime
$GPTOKEYB "$LOVE_GPTK" -c "./gravitycircuit.gptk" &
pm_platform_helper "$LOVE_BINARY"
$LOVE_RUN ./gamedata

# Cleanup any running gptokeyb instances, and any platform specific stuff.
pm_finish
