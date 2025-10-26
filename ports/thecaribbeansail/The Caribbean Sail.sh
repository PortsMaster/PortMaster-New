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
export PORT_32BIT="Y"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# Variables
GAMEDIR="/$directory/ports/thecaribbeansail"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO chmod +x "$GAMEDIR/gmloadernext.armhf"
$ESUDO chmod +x "$GAMEDIR/tools/splash"
$ESUDO chmod +x "$GAMEDIR/tools/text_viewer"
$ESUDO chmod +x "$GAMEDIR/tools/oggenc"
$ESUDO chmod +x "$GAMEDIR/tools/oggdec"
$ESUDO chmod +x "$GAMEDIR/tools/gmKtool.py"

# Patcher config
export PATCHER_FILE="$GAMEDIR/tools/patchscript"
export PATCHER_GAME="$(basename "${0%.*}")" # This gets the current script filename without the extension
export PATCHER_TIME="2 to 5 minutes"

# Exports
export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs.armhf:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export PATH="$PATH:$GAMEDIR/tools"

# Check if patchlog.txt to skip patching
if [ ! -f patchlog.txt ]; then
    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb)
    else
        echo "This port requires the latest version of PortMaster."
        text_viewer -e -f 25 -w -t "PortMaster needs to be updated" -m "This port requires the latest version of PortMaster. Please update PortMaster first.\n\nPress SELECT to close this window."
        exit 0
    fi
else
    echo "Patching process already completed. Skipping."
fi

# Display loading splash
$ESUDO ./tools/splash "splash.png" 2000 &

# Assign configs and load the game
$GPTOKEYB "gmloadernext.armhf" -c "thecaribbeansail.gptk" &
pm_platform_helper "${GAMEDIR}/gmloadernext.armhf"
./gmloadernext.armhf -c gmloader.json

# Cleanup
pm_finish
