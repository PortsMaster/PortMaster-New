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
GAMEDIR="/$directory/ports/watchduckslegacy"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# cd and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64
$ESUDO chmod +x $GAMEDIR/7z.aarch64

# exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# extract and game files
if [ -f "./assets/Watch Ducks Legacy.exe" ]; then
  mv "./assets/Watch Ducks Legacy.exe" "./assets/Watch Ducks Legacy.7z"
  pm_message "Extracting Watch Ducks Legacy ..."
  ./7z.aarch64 x "./assets/Watch Ducks Legacy.7z" -o"./assets/" -y
  rm "./assets/Watch Ducks Legacy.7z"
  rm ./assets/*.{exe,dll}
  pm_message "Extraction complete"
fi

# patch file
if [ -f "./assets/data.win" ]; then
  pm_message "Patching game ..."
  $controlfolder/xdelta3 -d -s "./assets/data.win" "./assets/patch.xdelta3" "./assets/game.droid"
  [ $? -eq 0 ] && rm "./assets/data.win" || echo "Patching has failed"
  pm_message "Patching complete"
fi

# assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "watchduckslegacy.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# cleanup
pm_finish
