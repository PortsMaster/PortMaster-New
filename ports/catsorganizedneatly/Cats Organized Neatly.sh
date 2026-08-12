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
GAMEDIR="/$directory/ports/catsorganizedneatly"

# CD and set logging
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Permissions
$ESUDO chmod +x "$GAMEDIR/gmloadernext.aarch64"
$ESUDO chmod +x "$GAMEDIR/tools/gmtoolkit.aarch64"

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Adjust dpad_mouse_step, deadzone_scale and mouse delay based on resolution width
if [ "$DISPLAY_WIDTH" -lt 1280 ]; then
    echo "Setting dpad_mouse_step and deadzone_scale to 4 and mouse_delay to 8"
    sed -i -E 's/(dpad_mouse_step|deadzone_scale) = [0-9]/\1 = 4/g' catsorganizedneatly.gptk
	sed -i -E 's/(mouse_delay) = [0-9]/\1 = 9/g' catsorganizedneatly.gptk
elif [ "$DISPLAY_WIDTH" -lt 1920 ]; then
    echo "Setting dpad_mouse_step and deadzone_scale to 3, and mouse_delay to 4"
    sed -i -E 's/(dpad_mouse_step|deadzone_scale) = [0-9]/\1 = 3/g' catsorganizedneatly.gptk
	sed -i -E 's/(mouse_delay) = [0-9]/\1 = 4/g' catsorganizedneatly.gptk
else
    echo "Setting dpad_mouse_step and deadzone_scale to 9, and mouse_delay to 4"
    sed -i -E 's/(dpad_mouse_step|deadzone_scale) = [0-9]/\1 = 9/g' catsorganizedneatly.gptk
	sed -i -E 's/(mouse_delay) = [0-9]/\1 = 4/g' catsorganizedneatly.gptk
fi

# Disable cursor auto-hide if on Rocknix
if [[ ${CFW_NAME} == ROCKNIX ]]; then
  swaymsg 'seat * hide_cursor 0'
  NOHIDING=true
fi

# Check if we need to patch the game
if [ ! -f patchlog.txt ] || [ -f "$GAMEDIR/assets/data.win" ]; then
    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        export PATCHER_FILE="$GAMEDIR/tools/patchscript"
        export PATCHER_GAME="$(basename "${0%.*}")"
        export PATCHER_TIME="7 to 10 minutes"
        export controlfolder
        export ESUDO
	export DEVICE_ARCH
        chmod +x "$PATCHER_FILE"
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb)
    else
        echo "This port requires the latest version of PortMaster."
    fi
fi

# Assign gptokeyb and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "catsorganizedneatly.gptk" &
pm_platform_helper "gmloadernext.aarch64" >/dev/null

# Let's not load the external cursor under Rocknix as it can be somewhat glitchy in boarders.
if [[ ${NOHIDING} == true ]]; then
	"$GAMEDIR/gmloadernext.aarch64" -c gmloader.json
else
	LD_PRELOAD="$GAMEDIR/lib/sdl_cursor.so" "$GAMEDIR/gmloadernext.aarch64" -c gmloader.json
fi

# Cleanup
pm_finish