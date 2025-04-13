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
GAMEDIR="/$directory/ports/fallenleaf"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

chmod 777 "$GAMEDIR/tools/patchscript"
chmod 777 "$GAMEDIR/tools/splash"
chmod 777 "$GAMEDIR/gmloadernext.aarch64"

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/lib:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export PATCHER_FILE="$GAMEDIR/tools/patchscript"
export PATCHER_GAME="$(basename "${0%.*}")" # This gets the current script filename without the extension
export PATCHER_TIME="5 to 10 minutes"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Check if we need to patch the game
if [ ! -f patchlog.txt ] || [ -f $GAMEDIR/assets/data.win ]; then
    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb)
    else
        echo "This port requires the latest version of PortMaster."
    fi
else
    echo "Patching process already completed. Skipping."
fi

# Display loading splash
if [ -f "$GAMEDIR/patchlog.txt" ]; then
    # Generate a random number (1, 2, or 3)
    RND=$(od -An -N1 -tu1 /dev/urandom)
    RND=$(( (RND % 3) + 1 ))

    # Select splash image based on random number
    case $RND in
        1) SPLASH="$GAMEDIR/tools/splash-1.png" ;;
        2) SPLASH="$GAMEDIR/tools/splash-2.png" ;;
        3) SPLASH="$GAMEDIR/tools/splash-3.png" ;;
    esac

    [ "$CFW_NAME" = "muOS" ] && $ESUDO "$GAMEDIR/tools/splash" "$SPLASH" 1
    $ESUDO "$GAMEDIR/tools/splash" "$SPLASH" 20000 &
fi

swapabxy() {
    PYTHON=$(which python3)
    # Update SDL_GAMECONTROLLERCONFIG to swap a/b and x/y button

    if [ "$CFW_NAME" == "knulli" ] && [ -f "$SDL_GAMECONTROLLERCONFIG_FILE" ];then
	      # Knulli seems to use SDL_GAMECONTROLLERCONFIG_FILE (on rg40xxh at least)
        cat "$SDL_GAMECONTROLLERCONFIG_FILE" | $PYTHON $GAMEDIR/tools/swapabxy.py > "$GAMEDIR/gamecontrollerdb_swapped.txt"
	      export SDL_GAMECONTROLLERCONFIG_FILE="$GAMEDIR/gamecontrollerdb_swapped.txt"
    else
        # Other CFW use SDL_GAMECONTROLLERCONFIG
        export SDL_GAMECONTROLLERCONFIG="`echo "$SDL_GAMECONTROLLERCONFIG" | $PYTHON $GAMEDIR/tools/swapabxy.py`"
    fi
}

# Swap a/b and x/y button if needed
if [ -f "$GAMEDIR/swapabxy.txt" ]; then
    swapabxy
fi

# Assign gptokeyb and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "fallenleaf.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64" >/dev/null
./gmloadernext.aarch64 -c gmloader.json

# Cleanup
pm_finish
