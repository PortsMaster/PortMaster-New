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
if [ -z ${TASKSET+x} ]; then
  source $controlfolder/tasksetter
fi
get_controls

# Variables
GAMEDIR="$directory/ports/openrct2"
ARGS="--user-data-path=save --openrct2-data-path=engine/share/openrct2 --rct2-data-path=RCT2/ --rct1-data-path=RCT1/"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x -R $GAMEDIR/*

# Exports
export TEXTINPUTPRESET="Name"
export TEXTINPUTINTERACTIVE="Y"
export TEXTINPUTNOAUTOCAPITALS="Y"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

## Check for game files
if [ ! -f "$GAMEDIR/RCT2/Data/g1.dat" ]; then
  pm_message "Missing game files, see README for more info."
  sleep 5
  exit 1
fi

# Extract the game if it exists
if [ -f "$GAMEDIR/engine.zip" ]; then
  if [ -d "$GAMEDIR/engine" ]; then
    pm_message "Removing old engine. One moment."
    $ESUDO rm -fRv "$GAMEDIR/engine"
  fi

  # Extract the engine from the build zip.
  pm_message "Extracting engine files. Please wait."
  $ESUDO unzip "$GAMEDIR/engine.zip"
  $ESUDO mv -fv "$GAMEDIR/engine/bin/openrct2" "$GAMEDIR/openrct2"
  $ESUDO rm -f "$GAMEDIR/engine.zip"
fi

# Run the game
pm_message "Starting game."
$GPTOKEYB "openrct2" -c openrct2.gptk &
pm_platform_helper "$GAMEDIR/openrct2"
$TASKSET ./openrct2 $ARGS

# Cleanup
pm_finish

