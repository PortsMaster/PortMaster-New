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

GAMEDIR=/$directory/ports/mybigsister

# Enable logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Enter the gamedir
cd $GAMEDIR

# Setup savedir
mkdir -p "$GAMEDIR/savedata"
bind_directories ~/.local/share/ags/My\ Big\ Sister "$GAMEDIR/savedata"

# Copy acsetup.cfg
if [ ! -f "$GAMEDIR/.initial_config_done" ]; then
	cp config/acsetup.cfg gamedata/
	touch "$GAMEDIR/.initial_config_done"
fi

# Exports
export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Launch the game
$GPTOKEYB "ags" -c "./controls.gptk" &
pm_platform_helper "$GAMEDIR/ags"
"$GAMEDIR/ags" ./gamedata

# cleanup
pm_finish

