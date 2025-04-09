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

GAMEDIR=/$directory/ports/riskofrain

# Enable logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd "$GAMEDIR"

# Set file permissions
$ESUDO chmod +x "$GAMEDIR/gmloadernext.armhf"
$ESUDO chmod +x "$GAMEDIR/tools/text_viewer"

# Patcher config
export PATCHER_FILE="$GAMEDIR/tools/patchscript"
export PATCHER_GAME="$(basename "${0%.*}")" # This gets the current script filename without the extension
export PATCHER_TIME="1 to 2 minutes"

# Exports
export LD_LIBRARY_PATH="/usr/lib:/usr/lib32:/$GAMEDIR/libs.armhf:$LD_LIBRARY_PATH"
export PATH="$PATH:$GAMEDIR/tools"

# If previous installation (671b20f) 
# remove patchlog.txt so that Patcher
# will update properly
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

$GPTOKEYB "gmloadernext.armhf" -c "./riskofrain.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.armhf"

./gmloadernext.armhf -c gmloader.json

pm_finish
