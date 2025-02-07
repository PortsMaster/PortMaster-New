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
GAMEDIR="/$directory/ports/leapyear"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Extract and patch file
if [ -f "./assets/data.win" ]; then
  if [ "$(md5sum "./assets/data.win" | awk '{print $1}')" == "9ceb853d5bd622c94c5bbe10945bfe4d" ]; then
    # itch
    $controlfolder/xdelta3 -d -s "./assets/data.win" "./patch/itch_patch.xdelta" "./assets/game.droid"
  elif [ "$(md5sum "./assets/data.win" | awk '{print $1}')" == "0d19cb03cf680cd2e8c0965f9d295630" ]; then
    # Steam
    $controlfolder/xdelta3 -d -s "./assets/data.win" "./patch/steam_patch.xdelta" "./assets/game.droid"
  fi      
  [ $? -eq 0 ] && rm "./assets/data.win" || pm_message "Failed to apply patch"
  # Delete redundant files
  rm -f assets/*.{dll,exe}
  # Zip audio files into the game.port
	zip -r -0 ./game.port ./assets/audiogroup1.dat
fi

# Assign gptokeyb and load the game
$GPTOKEYB "gmloadernext.aarch64" xbox360 &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "gmloader.json"

# Cleanup
pm_finish