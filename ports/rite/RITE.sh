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
GAMEDIR="/$directory/ports/rite"
GMLOADER_JSON="$GAMEDIR/gmloader.json"
TOOLDIR="$GAMEDIR/tools"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Ensure executable permissions
$ESUDO chmod +x "$GAMEDIR/gmloadernext.aarch64"
$ESUDO chmod +x "$GAMEDIR/tools/SDL_swap_gpbuttons.py"

# Prepare game files
if [ -f ./assets/data.win ]; then
    # Apply a patch
        checksum=$(md5sum "./assets/data.win" | awk '{print $1}')
    if [ "$checksum" = "b74c9aac95bd6e0a202651550e1c200c" ]; then # itch.io version
        $ESUDO $controlfolder/xdelta3 -d -s assets/data.win -f ./tools/patch-itch.xdelta assets/game.droid && \
        rm gamedata/data.win
        rm -f assets/*.{exe,dll}
        zip -r -0 ./game.port ./assets/
        rm -Rf ./assets/
    elif [ "$checksum" = "e49fe35d97a2b2655b672883b4ecd8a1" ]; then # steam version
        $ESUDO $controlfolder/xdelta3 -d -s assets/data.win -f ./tools/patch-steam.xdelta assets/game.droid && \
        rm gamedata/data.win
        rm -f assets/*.{exe,dll}
        zip -r -0 ./game.port ./assets/
        rm -Rf ./assets/
    else
        echo "Error: MD5 checksum of data.win does not match one of the expected checksums."    
    fi
else
    echo "Error: Missing files in assets folder OR game has been patched"
fi

# Swap buttons
"$GAMEDIR/tools/SDL_swap_gpbuttons.py" -i "$SDL_GAMECONTROLLERCONFIG_FILE" -o "$GAMEDIR/gamecontrollerdb_swapped.txt" -l "$GAMEDIR/SDL_swap_gpbuttons.txt"
export SDL_GAMECONTROLLERCONFIG_FILE="$GAMEDIR/gamecontrollerdb_swapped.txt"
export SDL_GAMECONTROLLERCONFIG="`echo "$SDL_GAMECONTROLLERCONFIG" | "$GAMEDIR/tools/SDL_swap_gpbuttons.py" -l "$GAMEDIR/SDL_swap_gpbuttons.txt"`"

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "rite.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish