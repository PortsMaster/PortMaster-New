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

GAMEDIR=/$directory/ports/interstatedrifter

# Enable logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd "$GAMEDIR"

# Set file permissions
$ESUDO chmod +x "$GAMEDIR/gmloadernext.aarch64"
$ESUDO chmod +x "$GAMEDIR/tools/toolscript"
$ESUDO chmod +x "$GAMEDIR/tools/7zzs"
dos2unix "$GAMEDIR/tools/toolscript"

# Patcher config
export PATCHER_FILE="$GAMEDIR/tools/toolscript"
export PATCHER_GAME="$(basename "${0%.*}")" 
export PATCHER_TIME="1 to 2 minutes"

# Exports
export LD_LIBRARY_PATH="/usr/lib:/$GAMEDIR/libs.aarch64:$LD_LIBRARY_PATH"
export PATH="$PATH:$GAMEDIR/tools"

# Check for install_completed to skip patching
if [ ! -f install_completed ]; then 
    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        source "$controlfolder/utils/patcher.txt"
    else
        pm_message "This port requires the latest version of PortMaster."
        exit 1  # Exit to prevent further execution
    fi
else
    pm_message "Patching process already completed. Skipping."
fi

$GPTOKEYB "gmloadernext.aarch64" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c gmloader.json

pm_finish
