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
GAMEDIR="/$directory/ports/operiusdx"

# CD and set log
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Ensure executable permissions
$ESUDO chmod +x "$GAMEDIR/gmloadernext.aarch64"
$ESUDO chmod +x "$GAMEDIR/tools/patchscript"
$ESUDO chmod +x "$GAMEDIR/tools/splash"
$ESUDO chmod +x $GAMEDIR/tools/SDL_swap_gpbuttons.py

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/lib:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export ESUDO
export controlfolder 

# Check for any .zip files
if compgen -G "$GAMEDIR/*.zip" > /dev/null; then
    mkdir -p "$GAMEDIR/assets" || exit 1
    
    for zipfile in "$GAMEDIR"/*.zip; do
        [ -f "$zipfile" ] || continue
        echo "Extracting: $(basename "$zipfile")..."
        if unzip -n -q "$zipfile" -d "$GAMEDIR/assets"; then
            echo "Successfully extracted $(basename "$zipfile")"
            rm -f "$zipfile"
        else
            echo "Failed to extract $(basename "$zipfile")"
            exit 1
        fi
    done
else
    echo "No .zip files found in $GAMEDIR"
fi

# Check if we need to patch the game
if [ -f assets/data.win ]; then
    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        export PATCHER_FILE="$GAMEDIR/tools/patchscript"
        export PATCHER_GAME="Operius DX"
        export PATCHER_TIME="less than a minute"
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb)
    else
        pm_message "This port requires the latest version of PortMaster."
    fi
fi

# Apply Swap buttons for non CrossMix devices
if [[ ! "${CFW_NAME}" == "TrimUI" ]]; then
    cat > "$GAMEDIR/SDL_swap_gpbuttons.txt" << 'EOF'
a b
x y
EOF
fi

# Swap buttons
"$GAMEDIR/tools/SDL_swap_gpbuttons.py" -i "$SDL_GAMECONTROLLERCONFIG_FILE" -o "$GAMEDIR/gamecontrollerdb_swapped.txt" -l "$GAMEDIR/SDL_swap_gpbuttons.txt"
export SDL_GAMECONTROLLERCONFIG_FILE="$GAMEDIR/gamecontrollerdb_swapped.txt"
export SDL_GAMECONTROLLERCONFIG="`echo "$SDL_GAMECONTROLLERCONFIG" | "$GAMEDIR/tools/SDL_swap_gpbuttons.py" -l "$GAMEDIR/SDL_swap_gpbuttons.txt"`"

# Display loading splash
if [ ! -f assets/data.win ]; then
    $ESUDO "$GAMEDIR/tools/splash" "$GAMEDIR/splash.png" 4000 & 
fi

# Assign gptokeyb and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "operiusdx.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64" >/dev/null
./gmloadernext.aarch64 -c gmloader.json

# Cleanup
pm_finish
