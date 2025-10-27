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
GAMEDIR="/$directory/ports/overbowed"

# cd and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64

# prepare game files
if [ -f "./assets/data.win" ]; then
  pm_message "Preparing game files ..."
  # determine version
  checksum=$(md5sum "assets/data.win" | awk '{print $1}')
  if [ "$checksum" = "fd40bc9db283169b69f53f65b61c617c" ]; then
    touch ver_itch
  else
    touch ver_steam
  fi
  # prepare files
  mv "./assets/data.win" "./assets/game.droid"
  rm -f ./assets/*.exe ./assets/*.dll
  # pick wrapper based on marker file
  if [ -f "ver_itch" ]; then
    wrapper="./overbowed_itch.port"
  elif [ -f "ver_steam" ]; then
    wrapper="./overbowed_steam.port"
  fi
  # archive .port
  pm_message "Finalizing .port file ..."
  zip -r -0 "$wrapper" "./assets/"
  rm -rf "./assets/"
fi

# exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# assign configs and load the game
if [ -f "ver_itch" ]; then
  GMLOADER_JSON="$GAMEDIR/gmloader_itch.json"
elif [ -f "ver_steam" ]; then
  GMLOADER_JSON="$GAMEDIR/gmloader_steam.json"
fi
$GPTOKEYB "gmloadernext.aarch64" & #-c "overbowed.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# cleanup
pm_finish
