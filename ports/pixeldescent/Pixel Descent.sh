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
GAMEDIR="/$directory/ports/pixeldescent"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64
$ESUDO chmod +x $GAMEDIR/tools/splash

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"

# Zip data if necessary
zip_archive() {
    if [ -f "assets/data.win" ]; then
        mv "assets/data.win" "assets/game.droid"
    else
        pm_message "No assets in assets dir!"
        sleep 2
        exit 1
    fi
    rm -rf assets/*.exe assets/*.dll assets/.gitkeep
    echo "Removed unnecessary files"
    zip -r -0 pixeldescent.port ./assets/
    mkdir -p saves
    rm -rf assets
}

if [ -d assets ]; then
    zip_archive
fi

# Display loading splash
[ "$CFW_NAME" == "muOS" ] && $ESUDO ./tools/splash "splash.png" 1
$ESUDO ./tools/splash "splash.png" 5000 & 

# Assign gptokeyb and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "pixeldescent.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64" >/dev/null
./gmloadernext.aarch64 -c gmloader.json

# Kill processes
pm_finish
