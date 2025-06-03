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

# Variables
GAMEDIR="/$directory/ports/shackolantern"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64

# Extract file
if [ -f "./assets/Shack-o'-Lantern.exe" ]; then
  # Extract its contents in place using 7z
  pm_message "Extracting Shack-o'-Lantern.exe ..."
  ./7z x "./assets/Shack-o'-Lantern.exe" -o"./assets/" -y
  pm_message "Extraction complete"
fi

# Patch data.win file
if [ -f "./assets/data.win" ]; then
  $controlfolder/xdelta3 -d -s "./assets/data.win" "./assets/patch.xdelta3" "./assets/game.droid"
  [ $? -eq 0 ] && rm "./assets/data.win" || pm_message "Patching of data.win has failed"
  pm_message "Patching complete"
  # Delete unneeded files
  rm -f assets/*.{dll,exe}
fi

# Prepare game files
if [ -f ./assets/game.droid ]; then
  zip -r -0 ./shackolantern.port ./assets/
  rm -Rf ./assets/
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "shackolantern.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish
