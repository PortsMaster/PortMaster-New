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
GAMEDIR="/$directory/ports/thedeadprince"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [ -f "./assets/data.win" ]; then
    $controlfolder/xdelta3 -d -s "./assets/data.win" "./patch/data.win.xdelta3" "./assets/game.droid"
    if [ $? -eq 0 ]; then
        rm "./assets/data.win"
        pm_message "Patching of data.win done successfully"
    else
        pm_message "Patching of data.win has failed"
	exit 1
    fi
fi

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64

# Prepare game files
if [ -f ./assets/game.droid ]; then
	# Delete all redundant files
	rm -f assets/*.{dll,exe,txt}
# Zip all game files into the paid.port
  zip -r -0 ./paid.port ./assets/
  # Overwrite gmloader.json
  mv -f paid-gmloader.json gmloader.json
    rm -f $GAMEDIR/demo.port
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "thedeadprince.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
LD_PRELOAD="$GAMEDIR/lib/sdl_cursor.so" ./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish
