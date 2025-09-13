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

source "$controlfolder/control.txt"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# variables
GAMEDIR="/$directory/ports/macchasworld"

# cd and set log
cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# prepare game files
if [ -f ./assets/data.win ]; then
  # rename data.win
  [ -f "./assets/data.win" ] && mv assets/data.win assets/game.droid
  # delete redundant files
  rm -f assets/*.{exe,dll}
fi

# assign gptokeyb and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "./macchasworld.gptk" &
pm_platform_helper "gmloadernext.aarch64"
./gmloadernext.aarch64 -c gmloader.json

# cleanup
pm_finish

