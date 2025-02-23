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
GAMEDIR="/$directory/ports/digitaltamersreborn"
BIG_SCALE=4000
BIG_DELAY=8
SMALL_SCALE=6000
SMALL_DELAY=16

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x -R $GAMEDIR/*

# Exports
export PATCHER_FILE="$GAMEDIR/tools/patchscript"
export PATCHER_GAME="$(basename "${0%.*}")" # This gets the current script filename without the extension
export PATCHER_TIME="2 to 5 minutes"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# dos2unix in case we need it
dos2unix "$GAMEDIR/tools/gmKtool.py"
dos2unix "$GAMEDIR/tools/Klib/GMblob.py"
dos2unix "$GAMEDIR/tools/patchscript"

# Check if patchlog.txt to skip patching
if [ ! -f patchlog.txt ]; then
    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb)
    else
        echo "This port requires the latest version of PortMaster."
    fi
else
    echo "Patching process already completed. Skipping."
fi

# Post patcher setup
export PORT_32BIT="Y"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/lib:$LD_LIBRARY_PATH"

# Apply mouse scaling according to screen size
if [ $DISPLAY_WIDTH -gt 480 ]; then
    sed -i "s/^mouse_scale *= *[0-9]\+/mouse_scale = $BIG_SCALE/" "$GAMEDIR/dtr.gptk"
    sed -i "s/^mouse_delay *= *[0-9]\+/mouse_delay = $BIG_DELAY/" "$GAMEDIR/dtr.gptk"
else
    sed -i "s/^mouse_scale *= *[0-9]\+/mouse_scale = $SMALL_SCALE/" "$GAMEDIR/dtr.gptk"
    sed -i "s/^mouse_delay *= *[0-9]\+/mouse_delay = $SMALL_DELAY/" "$GAMEDIR/dtr.gptk"
fi

# Display loading splash
if [ -f "$GAMEDIR/patchlog.txt" ]; then
    [ "$CFW_NAME" == "muOS" ] && $ESUDO ./tools/splash "splash.png" 1
    $ESUDO ./tools/splash "splash.png" 2000 &
fi

# Assign gptokeyb and load the game
$GPTOKEYB "gmloadernext.armhf" -c "dtr.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.armhf" >/dev/null
./gmloadernext.armhf -c gmloader.json

# Cleanup
pm_finish