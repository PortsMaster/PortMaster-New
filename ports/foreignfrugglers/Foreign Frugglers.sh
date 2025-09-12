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
GAMEDIR="/$directory/ports/foreignfrugglers"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# cd and logging
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64

# extract file
if [ -f "./assets/Foreign Frugglers.exe" ]; then
  # extract its contents in place using 7z
  pm_message "Extracting Foreign Frugglers.exe ..."
  ./7z x "./assets/Foreign Frugglers.exe" -o"./assets/" -y
  pm_message "Extraction complete"
fi

# prepare game files
if [ -f ./assets/data.win ]; then
  mv ./assets/data.win ./assets/game.droid 
  rm -f assets/*.{dll,exe}
  pm_message "Packing assets into foreignfrugglers.port ..."
  zip -r -0 ./foreignfrugglers.port ./assets/
  rm -Rf ./assets/
  pm_message "Packing complete"
fi

# assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "foreignfrugglers.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# cleanup
pm_finish
