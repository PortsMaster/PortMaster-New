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

# set project/game name here
GAME_NAME="astronautilus"
GAMEDIR="/$directory/ports/$GAME_NAME"

# cd and set permissions
cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x "$GAMEDIR/gmloadernext.aarch64"

# exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# prepare game files
if [ -f ./assets/data.win ]; then
  pm_message "Preparing game files ..."
  # check if demo version
  rm demo_version
  checksum=$(md5sum "./assets/data.win" | awk '{print $1}')
  if [ "$checksum" = "1a508aff40277892f85802fa9fdbe8f3" ]; then
    touch demo_version
    pm_message "Demo version detected ..."
    sleep 1
  fi
  # package files
  mv assets/data.win assets/game.droid
  rm -f assets/*.{exe,dll}
  zip -r -0 "./$GAME_NAME.port" ./assets/
  rm ./assets/*
fi

# assign configs and load the game
if [ -f demo_version ]; then
  pm_message "Launching demo version ..."
  sleep 1
  $GPTOKEYB "gmloadernext.aarch64" -c "${GAME_NAME}_demo_version.gptk" &
  pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
  ./gmloadernext.aarch64 -c "gmloader_demo_version.json"
else
  pm_message "Launching full version ..."
  sleep 1
  $GPTOKEYB "gmloadernext.aarch64" -c "$GAME_NAME.gptk" &
  pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
  ./gmloadernext.aarch64 -c "gmloader.json"
fi

# cleanup
pm_finish
