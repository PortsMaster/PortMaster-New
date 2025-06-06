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
GAMEDIR="/$directory/ports/darkdeity"

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Setup permissions
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64
$ESUDO chmod +x $GAMEDIR/tools/splash

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export controlfolder
export DEVICE_ARCH

# Check if patchlog.txt to skip patching
if [ ! -f patchlog.txt ] || [ -f "$GAMEDIR/assets/data.win" ]; then
    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        set -o pipefail
        
        # Setup mono environment variables
        DOTNETDIR="$HOME/mono"
        DOTNETFILE="$controlfolder/libs/dotnet-8.0.12.squashfs"
        $ESUDO mkdir -p "$DOTNETDIR"
        $ESUDO umount "$DOTNETFILE" || true
        $ESUDO mount "$DOTNETFILE" "$DOTNETDIR"
        export PATH="$DOTNETDIR":"$PATH"
            
        # Setup and execute the Portmaster Patcher utility with our patch file
        export PATCHER_FILE="$GAMEDIR/tools/patchscript"
        export PATCHER_GAME="$(basename "${0%.*}")"
        export PATCHER_TIME="a while"
        source "$controlfolder/utils/patcher.txt"
        $ESUDO umount "$DOTNETDIR"
    else
        pm_message "This port requires the latest version of PortMaster."
        pm_finish
        exit 1
    fi
fi

# Display loading splash
if [ -f "$GAMEDIR/patchlog.txt" ]; then
    $ESUDO "$GAMEDIR/tools/splash" "$GAMEDIR/splash.png" 1 
    $ESUDO "$GAMEDIR/tools/splash" "$GAMEDIR/splash.png" 4000 &
fi

# Run the game
$GPTOKEYB "gmloadernext.aarch64" -c "./darkdeity.gptk" & 
pm_platform_helper "gmloadernext.aarch64" >/dev/null
./gmloadernext.aarch64 -c gmloader.json

# Kill processes
pm_finish
