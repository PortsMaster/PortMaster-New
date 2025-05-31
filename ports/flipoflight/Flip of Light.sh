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
GAMEDIR="/$directory/ports/flipoflight"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
$ESUDO chmod +x $GAMEDIR/tools/SDL_swap_gpbuttons.py
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64

# Patch Game
if [ -f ./assets/data.win ]; then
checksum=$(md5sum "./assets/data.win" | awk '{print $1}')
    
    # Checksum for the Itch.io version
    if [ "$checksum" = "530460c1f15416a86d8790857d4935ca" ]; then
        $ESUDO $controlfolder/xdelta3 -d -s "$GAMEDIR/assets/data.win" "$GAMEDIR/tools/flipoflightitch.xdelta" "$GAMEDIR/assets/game.droid"
        rm assets/data.win
        pm_message "Itch.io data.win has been patched"
        # Checksum for the Steam version
    elif [ "$checksum" = "84d23ffa517188a15f49d8bb8df157a9" ]; then
        $ESUDO $controlfolder/xdelta3 -d -s "$GAMEDIR/assets/data.win" "$GAMEDIR/tools/flipoflightsteam.xdelta" "$GAMEDIR/assets/game.droid"
        rm assets/data.win
        pm_message "Steam data.win has been patched"
    else
        pm_message "Error: MD5 checksum of data.win does not match any expected version."
	exit 1
    fi
else    
        pm_message "Missing data.win in assets folder or game has been patched."
fi


# Prepare game files
if [ -f ./assets/game.droid ]; then
    # Delete all redundant files
    rm -f assets/*.{dll,exe,txt}
    # Zip all game files into the game.port
    zip -r -0 ./game.port ./assets/
    rm -Rf ./assets/
    mkdir -p saves
    pm_message "Flip of Light has been patched!"
fi

# Swap buttons
"$GAMEDIR/tools/SDL_swap_gpbuttons.py" -i "$SDL_GAMECONTROLLERCONFIG_FILE" -o "$GAMEDIR/gamecontrollerdb_swapped.txt" -l "$GAMEDIR/SDL_swap_gpbuttons.txt"
export SDL_GAMECONTROLLERCONFIG_FILE="$GAMEDIR/gamecontrollerdb_swapped.txt"
export SDL_GAMECONTROLLERCONFIG="`echo "$SDL_GAMECONTROLLERCONFIG" | "$GAMEDIR/tools/SDL_swap_gpbuttons.py" -l "$GAMEDIR/SDL_swap_gpbuttons.txt"`"

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish