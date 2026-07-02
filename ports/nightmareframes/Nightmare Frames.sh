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

GAMEDIR=/$directory/ports/nightmareframes

# Enable logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Enter the gamedir
cd $GAMEDIR

echo "DISPLAY_WIDTH: $DISPLAY_WIDTH"

# Adjust dpad_mouse_step and deadzone_scale based on resolution width
if [ "$DISPLAY_WIDTH" -lt 640 ]; then
    echo "Setting dpad_mouse_step and deadzone_scale to 4"
    sed -i -E 's/(dpad_mouse_step|deadzone_scale) = [0-9]/\1 = 4/g' nightmareframes.gptk
elif [ "$DISPLAY_WIDTH" -lt 1280 ]; then
    echo "Setting dpad_mouse_step and deadzone_scale to 5"
    sed -i -E 's/(dpad_mouse_step|deadzone_scale) = [0-9]/\1 = 5/g' nightmareframes.gptk
elif [ "$DISPLAY_WIDTH" -lt 1920 ]; then
    echo "Setting dpad_mouse_step and deadzone_scale to 6"
    sed -i -E 's/(dpad_mouse_step|deadzone_scale) = [0-9]/\1 = 6/g' nightmareframes.gptk
else
    echo "Setting dpad_mouse_step and deadzone_scale to 7"
    sed -i -E 's/(dpad_mouse_step|deadzone_scale) = [0-9]/\1 = 7/g' nightmareframes.gptk
fi

# Setup savedir
mkdir -p "$GAMEDIR/savedata"
if [ -f "$GAMEDIR/gamedata/Nightmare Frames Prologue.exe" ]; then
    bind_directories ~/.local/share/ags/Nightmare\ Frames\ Prologue "$GAMEDIR/savedata"
else
    bind_directories ~/.local/share/ags/Nightmare\ Frames "$GAMEDIR/savedata"
fi

# Copy acsetup.cfg from config to gamedata
if [ ! -f "$GAMEDIR/.initial_config_done" ]; then
    cp config/acsetup.cfg gamedata/
    touch "$GAMEDIR/.initial_config_done"
fi

# Exports
export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTINTERACTIVE="Y"

# Launch the game
$GPTOKEYB "ags" -c "./nightmareframes.gptk" &
pm_platform_helper "$GAMEDIR/ags"
"$GAMEDIR/ags" ./gamedata

# cleanup
pm_finish

