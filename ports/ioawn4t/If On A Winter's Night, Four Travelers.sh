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

# We source the control.txt file contents here
source $controlfolder/control.txt

# With device_info we can get dynamic device information like resolution, cpu, cfw etc.
source $controlfolder/device_info.txt

# We source custom mod files from the portmaster folder example mod_jelos.txt which containts pipewire fixes
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR=/$directory/ports/ioawn4t

# Enable logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Enter the gamedir
cd "$GAMEDIR"
echo "DISPLAY_WIDTH: $DISPLAY_WIDTH"

# Adjust dpad_mouse_step and deadzone_scale based on resolution width
if [ "$DISPLAY_WIDTH" -lt 640 ]; then
    echo "Setting dpad_mouse_step and deadzone_scale to 4"
    sed -i -E 's/(dpad_mouse_step|deadzone_scale) = [0-9]/\1 = 4/g' ioawn4t.gptk
elif [ "$DISPLAY_WIDTH" -lt 1280 ]; then
    echo "Setting dpad_mouse_step and deadzone_scale to 5"
    sed -i -E 's/(dpad_mouse_step|deadzone_scale) = [0-9]/\1 = 5/g' ioawn4t.gptk
elif [ "$DISPLAY_WIDTH" -lt 1920 ]; then
    echo "Setting dpad_mouse_step and deadzone_scale to 6"
    sed -i -E 's/(dpad_mouse_step|deadzone_scale) = [0-9]/\1 = 6/g' ioawn4t.gptk
else
    echo "Setting dpad_mouse_step and deadzone_scale to 7"
    sed -i -E 's/(dpad_mouse_step|deadzone_scale) = [0-9]/\1 = 7/g' ioawn4t.gptk
fi

# Setup savedir
mkdir -p "$GAMEDIR/savedata"
$ESUDO rm -rf ~/.local/share/ags/If\ On\ A\ Winter\'s\ Night\ Four\ Travelers
mkdir -p ~/.local/share
mkdir -p "$GAMEDIR/savedata"
ln -sfv "$GAMEDIR/savedata" ~/.local/share/ags/If\ On\ A\ Winter\'s\ Night\ Four\ Travelers

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

# We warn the user about the puzzle which needs keyboard inputs
./text_viewer -f 25 -w -t "Instructions" --input_file $GAMEDIR/instructions.txt

# Launch the game
$GPTOKEYB "ags" -c "./ioawn4t.gptk" &
./ags ./gamedata

# Cleanup
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0



