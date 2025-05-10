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

#
# THIS WAS TESTED WITH VERSION v1.1.271:
#
# Pizza Tower$ sha256sum data.win
# 698373e57a64a46d9857ba6dce9f6a300fce989d16c51cec6d58613fbd5ea599  data.win
# Download using the Steam Console: download_depot 2231450 2231451 2814056822728886841 
#

source $controlfolder/control.txt
source $controlfolder/tasksetter
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

export ESUDO=$ESUDO
export GAMEDIR="/$directory/ports/pizzatower"
cd "$GAMEDIR"

# Log execution
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Setup other misc environment variables
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}":"$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Ensure executable permissions
$ESUDO chmod +x "$GAMEDIR/gmloadernext.aarch64"
$ESUDO chmod +x "$GAMEDIR/tools/patchscript"

# Check if we need to patch
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
        export PATCHER_GAME="Pizza Tower"
		export PATCHER_TIME="5 to 10 minutes"
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
    [ "$CFW_NAME" == "muOS" ] && $ESUDO "$GAMEDIR/tools/splash" "$GAMEDIR/splash.png" 1 
    $ESUDO "$GAMEDIR/tools/splash" "$GAMEDIR/splash.png" 6000 &
fi

swapabxy() {
    # Update SDL_GAMECONTROLLERCONFIG to swap a/b and x/y button
    PYTHON=$(which python3)
    if [ "$CFW_NAME" == "knulli" ] && [ -f "$SDL_GAMECONTROLLERCONFIG_FILE" ];then
        cat "$SDL_GAMECONTROLLERCONFIG_FILE" | $PYTHON $GAMEDIR/tools/swapabxy.py > "$GAMEDIR/gamecontrollerdb_swapped.txt"
        export SDL_GAMECONTROLLERCONFIG_FILE="$GAMEDIR/gamecontrollerdb_swapped.txt"
    else
        export SDL_GAMECONTROLLERCONFIG="`echo "$SDL_GAMECONTROLLERCONFIG" | $PYTHON $GAMEDIR/tools/swapabxy.py`"
    fi
}

# Swap a/b and x/y button if needed
if [ -f "$GAMEDIR/swapabxy.txt" ]; then
    swapabxy
fi

$GPTOKEYB "gmloadernext.aarch64" -c "pizza.gptk" & 
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64" > /dev/null
$TASKSET ./gmloadernext.aarch64 -c gmloader.json

pm_finish