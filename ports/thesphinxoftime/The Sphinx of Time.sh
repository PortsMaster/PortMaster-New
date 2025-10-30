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
export controlfolder
source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# device (info resolution, cpu, cfw etc.)
source $controlfolder/device_info.txt

# custom mod files from the portmaster folder example mod_jelos.txt which containts pipewire fixes
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

# variables
GAMEDIR="/$directory/ports/thesphinxoftime"

# cd and logging
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# adjust dpad_mouse_step and deadzone_scale based on resolution width
echo "DISPLAY_WIDTH: $DISPLAY_WIDTH"
if [ "$DISPLAY_WIDTH" -lt 640 ]; then
  echo "Setting dpad_mouse_step and deadzone_scale to 4"
  sed -i -E 's/(dpad_mouse_step|deadzone_scale) = [0-9]/\1 = 4/g' thesphinxoftime.gptk
elif [ "$DISPLAY_WIDTH" -lt 1280 ]; then
  echo "Setting dpad_mouse_step and deadzone_scale to 5"
  sed -i -E 's/(dpad_mouse_step|deadzone_scale) = [0-9]/\1 = 5/g' thesphinxoftime.gptk
elif [ "$DISPLAY_WIDTH" -lt 1920 ]; then
  echo "Setting dpad_mouse_step and deadzone_scale to 6"
  sed -i -E 's/(dpad_mouse_step|deadzone_scale) = [0-9]/\1 = 6/g' thesphinxoftime.gptk
else
  echo "Setting dpad_mouse_step and deadzone_scale to 7"
  sed -i -E 's/(dpad_mouse_step|deadzone_scale) = [0-9]/\1 = 7/g' thesphinxoftime.gptk
fi

# set up save dir
mkdir -p "$GAMEDIR/savedata"
bind_directories ~/.local/share/ags/The\ Sphinx\ of\ Time "$GAMEDIR/savedata"

# copy acsetup.cfg from config to gamedata
if [ ! -f "$GAMEDIR/.initial_config_done" ]; then
  cp config/acsetup.cfg gamedata/
  touch "$GAMEDIR/.initial_config_done"
fi

# exports
export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTINTERACTIVE="Y"

# launch the game
$GPTOKEYB "$GAMEDIR/ags" -c "./thesphinxoftime.gptk" &
pm_platform_helper "$GAMEDIR/ags"
"$GAMEDIR/ags.aarch64" ./gamedata

# cleanup
pm_finish
