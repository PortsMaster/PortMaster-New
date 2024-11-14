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
GAMEDIR="/$directory/ports/topnep"
TOOLDIR="$GAMEDIR/tools"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x -R $GAMEDIR/*

$ESUDO chmod 777 "$TOOLDIR/splash"
$ESUDO chmod 777 "$TOOLDIR/gmKtool.py"
$ESUDO chmod 777 "$TOOLDIR/swapabxy.py"
$ESUDO chmod 777 "$GAMEDIR/gmloadernext"

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$TOOLDIR/libs:$LD_LIBRARY_PATH"
export PATH="$TOOLDIR:$PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export PATCHER_FILE="$GAMEDIR/patch/patchscript"
export PATCHER_GAME="Dimension Tripper Neptune: TOP NEP" 
export PATCHER_TIME="2 to 3 minutes"

# Check if patchlog.txt to skip patching
if [ ! -f patchlog.txt ]; then
    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb)
    else
        echo "This port requires the latest version of PortMaster." > $CUR_TTY
    fi
else
    echo "Patching process already completed. Skipping."
fi

# Swap a/b and x/y button if needed
if [ -f "$GAMEDIR/swapabxy.txt" ]; then
# Update SDL_GAMECONTROLLERCONFIG to swap a/b and x/y button
    if [ "$CFW_NAME" == "knulli" ] && [ -f "$SDL_GAMECONTROLLERCONFIG_FILE" ];then
	      # Knulli seems to use SDL_GAMECONTROLLERCONFIG_FILE (on rg40xxh at least)
        cat "$SDL_GAMECONTROLLERCONFIG_FILE" | swapabxy.py > "$GAMEDIR/gamecontrollerdb_swapped.txt"
	      export SDL_GAMECONTROLLERCONFIG_FILE="$GAMEDIR/gamecontrollerdb_swapped.txt"
    else
        # Other CFW use SDL_GAMECONTROLLERCONFIG
        export SDL_GAMECONTROLLERCONFIG="`echo "$SDL_GAMECONTROLLERCONFIG" | swapabxy.py`"
    fi    
fi

# Display loading splash
if [ -f "$GAMEDIR/gamedata/game.droid" ]; then
[ "$CFW_NAME" == "muOS" ] && $ESUDO ./tools/splash "splash.png" 1 # muOS only workaround
    $ESUDO ./tools/splash "splash.png" 2000
fi

# Run the game
$GPTOKEYB "gmloadernext" -c "./topnep.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext"
./gmloadernext

# Kill processes
pm_finish
