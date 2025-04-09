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
GAMEDIR="/$directory/ports/undergrave"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x -R $GAMEDIR/*

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Prepare files from Steam instalation
if [ -f "$GAMEDIR/gamedata/data.win" ]; then
  mv gamedata/data.win gamedata/game.droid

  # Move audiogroup files from gamedata folder to ./assets
  mkdir -p ./assets
  mv ./gamedata/*.dat ./assets/

  # Zip all .dat files into the undergrave.port
  zip -r -0 ./undergrave.port ./assets/
  rm -Rf "$GAMEDIR/assets/"
fi

# Check if Undergrave.apk exists in the gamedata folder
if [ -f "$GAMEDIR/gamedata/Undergrave.apk" ]; then
  # If the APK exists, modify gmloader.json
  sed -i 's|"apk_path" : "undergrave.port"|"apk_path" : "gamedata/Undergrave.apk"|' $GMLOADER_JSON
else
  # If the APK does not exist, revert gmloader.json to original state
  sed -i 's|"apk_path" : "gamedata/Undergrave.apk"|"apk_path" : "undergrave.port"|' $GMLOADER_JSON
fi

# Assign configs and load the game
$GPTOKEYB "gmloader.aarch64" &
pm_platform_helper "gmloader.aarch64"
./gmloader.aarch64 -c gmloader.json

# Cleanup
pm_finish