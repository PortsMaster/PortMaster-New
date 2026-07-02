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
#get_controls
GAMEDIR=/$directory/ports/ikemen/
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Provide appropriate controller configuration if it recognizes SDL controller input
# export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

pm_platform_helper "$GAMEDIR/ikemen_linux.${DEVICE_ARCH}"
$GPTOKEYB "ikemen_linux.${DEVICE_ARCH}" &

# Check directory and create if not exist
if [ ! -d "external" ]; then
  mkdir -p external
fi

# Copy entry of detected joystick in ${controlfolder}/gamecontrollerdb.txt to external/gamecontrollerdb.txt
if [ ! -f "external/gamecontrollerdb.txt" ]; then
  ./sdlGamepadMapper --guid "${controlfolder}/gamecontrollerdb.txt" "external/gamecontrollerdb.txt"
fi

# if gamecontrollerdb.txt still not exists , generate with sdlGamepadMapper
if [ ! -f "external/gamecontrollerdb.txt" ]; then
  ./sdlGamepadMapper "external/gamecontrollerdb.txt"
fi

if [ -d "$GAMEDIR/data/" ]; then
  ./ikemen_linux.${DEVICE_ARCH} -updatechar -updatestage -debug
else
  ./ikemen_linux.${DEVICE_ARCH} -installrun -debug
fi
pm_finish
