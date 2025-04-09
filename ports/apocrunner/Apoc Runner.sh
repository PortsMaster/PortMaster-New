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
GAMEDIR="/$directory/ports/apocrunner"
SPLASHFILE="splash.png"

# CD and set permissions
cd "$GAMEDIR" 
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x "$GAMEDIR/gmloadernext.aarch64"
$ESUDO chmod +x "$GAMEDIR/tools/splash"

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Display loading splash -  note: Due to bug in muOS, we call twice else not displayed
if [ "$CFW_NAME" == "muOS" ]; then
  $ESUDO ./tools/splash $SPLASHFILE 1 
fi
$ESUDO ./tools/splash $SPLASHFILE 5000

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c gmloader.json

# Cleanup
pm_finish
