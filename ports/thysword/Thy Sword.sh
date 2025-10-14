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
GAMEDIR="/$directory/ports/thysword"
GMLOADER_JSON="$GAMEDIR/gmloader.json"
TOOLDIR="$GAMEDIR/tools"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Check if we have new enough version of PortMaster that contains xdelta3
if [ ! -f "$controlfolder/xdelta3" ]; then
  pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
  sleep 5
  exit 1
fi

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Ensure executable permissions
$ESUDO chmod +x "$GAMEDIR/gmloadernext.aarch64"
$ESUDO chmod +x "$GAMEDIR/tools/splash"
$ESUDO chmod +x "$GAMEDIR/tools/SDL_swap_gpbuttons.py"

# Prepare game files and patch game
# If "./assets/data.win" exists and matches the checksum of the itch or steam versions
if [ -f "./assets/data.win" ]; then
    checksum=$(md5sum "./assets/data.win" | awk '{print $1}')
    
    # Checksum for the Steam version
    if [ "$checksum" = "aefda0536e3f55e0deac7d8e150ceb27" ]; then
        $ESUDO $controlfolder/xdelta3 -d -s assets/data.win -f ./tools/thyswordsteam.xdelta assets/game.droid && \
        rm ./assets/data.win
	    rm -f "./assets/place data.win here"
	    pm_message "Steam version of the game has been patched"
    # Checksum for the Itch version
    elif [ "$checksum" = "05e81de7e15b109379f91886230f8d05" ]; then
        $ESUDO $controlfolder/xdelta3 -d -s assets/data.win -f ./tools/thysworditch.xdelta assets/game.droid && \
        rm ./assets/data.win
        rm -f "./assets/place data.win here"
	    pm_message "Itch.io version of the game has been patched"
    else
        pm_message "Error: MD5 checksum of data.win does not match any expected version."
        exit 1
    fi
fi

# Zip assets into game.port
if [ -f ./assets/game.droid ]; then
	# Zip all game files into the game.port
	zip -r -0 ./game.port ./assets/
	rm -rf ./assets/
fi

# Swap buttons
"$GAMEDIR/tools/SDL_swap_gpbuttons.py" -i "$SDL_GAMECONTROLLERCONFIG_FILE" -o "$GAMEDIR/gamecontrollerdb_swapped.txt" -l "$GAMEDIR/SDL_swap_gpbuttons.txt"
export SDL_GAMECONTROLLERCONFIG_FILE="$GAMEDIR/gamecontrollerdb_swapped.txt"
export SDL_GAMECONTROLLERCONFIG="`pm_message "$SDL_GAMECONTROLLERCONFIG" | "$GAMEDIR/tools/SDL_swap_gpbuttons.py" -l "$GAMEDIR/SDL_swap_gpbuttons.txt"`"

# Display loading splash
if [ ! -d ./assets ]; then
    $ESUDO "$GAMEDIR/tools/splash" "$GAMEDIR/splash.png" 4000 & 
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "thysword.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish