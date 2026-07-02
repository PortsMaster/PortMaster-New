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

# variables
GAMEDIR="/$directory/ports/thesaloon"

# cd and set log
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# ensure executable permissions
$ESUDO chmod +x "$GAMEDIR/gmloadernext.aarch64"

# exports
export LD_LIBRARY_PATH="$GAMEDIR/lib:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export controlfolder

# prepare game files
if [ -f ./assets/data.win ]; then
  # rename data.win file
  mv assets/data.win assets/game.droid
  # delete all redundant files
  rm -f assets/*.{dll,exe,txt}
  # zip all game files into the game.port
  zip -r -0 ./game.port ./assets/
  rm -Rf ./assets/
fi

# assign gptokeyb and load game
$GPTOKEYB "gmloadernext.aarch64" -c "inputs.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64" >/dev/null
./gmloadernext.aarch64 -c gmloader.json

# cleanup
pm_finish

