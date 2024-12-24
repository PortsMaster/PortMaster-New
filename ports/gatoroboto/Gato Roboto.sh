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
GAMEDIR="/$directory/ports/gatoroboto"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO chmod +x $GAMEDIR/gmloadernext.${DEVICE_ARCH}
$ESUDO chmod +x $GAMEDIR/tools/splash
$ESUDO chmod +x $GAMEDIR/tools/text_viewer


# Exports
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export PATCHER_FILE="$GAMEDIR/patch/patchscript"
export PATCHER_GAME="Gato Roboto" 
export PATCHER_TIME="5-10 minutes"

# If a previous installation (5e4f49d) is present
# remove patchlog.txt so Patcher is launched to
# properly update it
[[ -f "$GAMEDIR/game.apk" ]] && rm "$GAMEDIR/patchlog.txt" \
&& export PATCHER_FILE="$GAMEDIR/tools/updatescript" \
&& export PATCHER_TIME="less than a minute"

# Check if patchlog.txt to skip patching
if [ ! -f patchlog.txt ]; then
    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb)
    else
        echo "This port requires the latest version of PortMaster."
        text_viewer -e -f 25 -w -t "PortMaster needs to be updated" -m "This port requires the latest version of PortMaster. Please update PortMaster first. Go to https://portmaster.games/ for more info.\n\nPress SELECT to close this window."
        exit 0
    fi
else
    echo "Patching process already completed. Skipping."
fi

# Display loading splash
if [ -f "$GAMEDIR/patchlog.txt" ]; then
    [ "$CFW_NAME" == "muOS" ] && $ESUDO ./tools/splash "splash.png" 1 # workaround for muOS
    $ESUDO ./tools/splash "splash.png" 2000 &
fi

# Run the game
$GPTOKEYB "gmloadernext.${DEVICE_ARCH}" &
pm_platform_helper "$GAMEDIR/gmloadernext.${DEVICE_ARCH}"
./gmloadernext.${DEVICE_ARCH} -c gmloader.json

# Kill processes
pm_finish
