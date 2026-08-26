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
GAMEDIR=/$directory/ports/superstartrek/

# Exports
export LD_LIBRARY_PATH="/usr/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTINTERACTIVE="Y"

# Switch to the game directory
cd $GAMEDIR

# Log the execution of the script, the script overwrites itself on each launch
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

echo "DISPLAY_WIDTH: $DISPLAY_WIDTH"

# Adjust dpad_mouse_step and deadzone_scale based on resolution width
if [ "$DISPLAY_WIDTH" -lt 640 ]; then
    echo "Setting dpad_mouse_step and deadzone_scale to 4"
    sed -i -E 's/(dpad_mouse_step|deadzone_scale) = [0-9]/\1 = 4/g' superstartrek.gptk
elif [ "$DISPLAY_WIDTH" -lt 1280 ]; then
    echo "Setting dpad_mouse_step and deadzone_scale to 5"
    sed -i -E 's/(dpad_mouse_step|deadzone_scale) = [0-9]/\1 = 5/g' superstartrek.gptk
elif [ "$DISPLAY_WIDTH" -lt 1920 ]; then
    echo "Setting dpad_mouse_step and deadzone_scale to 6"
    sed -i -E 's/(dpad_mouse_step|deadzone_scale) = [0-9]/\1 = 9/g' superstartrek.gptk
else
    echo "Setting dpad_mouse_step and deadzone_scale to 7"
    sed -i -E 's/(dpad_mouse_step|deadzone_scale) = [0-9]/\1 = 9/g' superstartrek.gptk
fi

# Setup savedir
mkdir -p "$GAMEDIR/savedata"
bind_directories $GAMEDIR/savedata $HOME/.local/share/ags/Super\ Star\ Trek\ 25th


# Copy acsetup.cfg from config to gamedata
if [ ! -f "$GAMEDIR/.initial_config_done" ]; then
  cp config/acsetup.cfg gamedata/
  touch "$GAMEDIR/.initial_config_done"
fi

# Fix mouse resetting under Rocknix
if [ "$CFW_NAME" = "ROCKNIX" ]; then
  export SDL_TOUCH_MOUSE_EVENTS=0
  swaymsg input type:touch events disabled 2>/dev/null
  swaymsg seat '*' hide_cursor 0 2>/dev/null
  trap 'swaymsg seat "*" hide_cursor 1000 2>/dev/null' EXIT
fi

# Launch the game
$GPTOKEYB "ags" -c "./superstartrek.gptk" &
pm_platform_helper "$GAMEDIR/ags"
./ags gamedata 

# Cleanup 
pm_finish


