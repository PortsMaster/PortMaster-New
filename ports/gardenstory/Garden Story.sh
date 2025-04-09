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
GAMEDIR="/$directory/ports/gardenstory"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"

# Check if "data.win" exists and determine its checksum
if [ -f "assets/data.win" ]; then
    checksum=$(md5sum "assets/data.win" | awk '{print $1}')

    if [ "$checksum" = "ad61dfb29cda512397bf34a4aa70db8a" ]; then
        patch_file="patch-steam.xdelta"
    elif [ "$checksum" = "77eb9405465c7f8eae1d8317f9141373" ]; then
        patch_file="patch-epic.xdelta"
    else
        echo "Unknown data.win checksum: $checksum"
        exit 1
    fi

    # Apply the appropriate patch
    $ESUDO $controlfolder/xdelta3 -d -s "assets/data.win" -f "./patch/$patch_file" "assets/game.droid" && \
    rm "assets/data.win"
fi

# Zip the assets folder into the port
zip -r -0 gardenstory.port ./assets/
rm -rf ./assets
mkdir -p saves

# Display loading splash
[ "$CFW_NAME" == "muOS" ] && $ESUDO ./tools/splash "screenshot.png" 1
$ESUDO ./tools/splash "screenshot.png" 2000 &

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" &
pm_platform_helper "gmloadernext.aarch64"
./gmloadernext.aarch64 -c gmloader.json

# Kill processes
pm_finish
