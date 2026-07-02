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
GAMEDIR="/$directory/ports/crabjuice"

# cd and set log
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# ensure executable permissions
$ESUDO chmod +x "$GAMEDIR/gmloadernext.aarch64"

# exports
export LD_LIBRARY_PATH="$GAMEDIR/lib:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export controlfolder

# patch game & prepare game files
if [ -f assets/data.win ]; then
  echo "data.win found -- starting patch process ..."
  $ESUDO $controlfolder/xdelta3 -d -s assets/data.win -f ./patch.xdelta3 assets/game.droid
  if [ $? -ne 0 ]; then
    echo "Patch failed. Aborting packaging."
    exit 1
  fi
  rm -f assets/*.{dll,exe,txt}
  rm -f assets/data.win
  zip -r -0 ./game.port ./assets/
  rm -Rf ./assets/
  echo "Done."
else
  echo "assets/data.win not found."
fi

# assign gptokeyb and load game
$GPTOKEYB "gmloadernext.aarch64" -c "inputs.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64" >/dev/null
./gmloadernext.aarch64 -c gmloader.json

# cleanup
pm_finish

