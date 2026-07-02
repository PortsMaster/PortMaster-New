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

GAMEDIR="/$directory/ports/bloonstdx"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# CD and set permissions
cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64

# Adjust dpad_mouse_step, deadzone_scale and mouse delay based on resolution width
if [ "$DISPLAY_WIDTH" -lt 1280 ]; then
    echo "Setting dpad_mouse_step and deadzone_scale to 4 and mouse_delay to 8"
    sed -i -E 's/(dpad_mouse_step|deadzone_scale) = [0-9]/\1 = 4/g' bloonstdx.gptk
	sed -i -E 's/(mouse_delay) = [0-9]/\1 = 9/g' bloonstdx.gptk
elif [ "$DISPLAY_WIDTH" -lt 1920 ]; then
    echo "Setting dpad_mouse_step and deadzone_scale to 3, and mouse_delay to 4"
    sed -i -E 's/(dpad_mouse_step|deadzone_scale) = [0-9]/\1 = 3/g' bloonstdx.gptk
	sed -i -E 's/(mouse_delay) = [0-9]/\1 = 4/g' bloonstdx.gptk
else
    echo "Setting dpad_mouse_step and deadzone_scale to 9, and mouse_delay to 4"
    sed -i -E 's/(dpad_mouse_step|deadzone_scale) = [0-9]/\1 = 9/g' bloonstdx.gptk
	sed -i -E 's/(mouse_delay) = [0-9]/\1 = 4/g' bloonstdx.gptk
fi


# Disable cursor auto-hide if on Rocknix
if [[ ${CFW_NAME} == ROCKNIX ]]; then
  swaymsg 'seat * hide_cursor 0'
  NOHIDING=true
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "bloonstdx.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"

# Let's not load the external cursor under Rocknix as it can be somewhat glitchy in boarders.
if [[ ${NOHIDING} == true ]]; then
	./gmloadernext.aarch64 -c "$GMLOADER_JSON"
else
	LD_PRELOAD="$GAMEDIR/libs/sdl_cursor.so" ./gmloadernext.aarch64 -c "$GMLOADER_JSON"
fi

# Cleanup
pm_finish

# Auto-hide can resume now
if [ "$NOHIDING" = true ]; then
  swaymsg 'seat * hide_cursor 1000'
fi