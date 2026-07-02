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
GAMEDIR="/$directory/ports/frogforce"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64

# Disable cursor auto-hide if on Rocknix
if [[ ${CFW_NAME} == ROCKNIX ]]; then
  swaymsg 'seat * hide_cursor 0'
  NOHIDING=true
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "frogforce.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
LD_PRELOAD="$GAMEDIR/libs/sdl_cursor.so" ./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish

# Auto-hide can resume now
if [ "$NOHIDING" = true ]; then
  swaymsg 'seat * hide_cursor 1000'
fi