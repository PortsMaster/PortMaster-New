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

GAMEDIR=/$directory/ports/clockwind/
CONFDIR="$GAMEDIR/conf/"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1


# Ensure the conf directory exists
mkdir -p "$GAMEDIR/conf"

#DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"

# Set the XDG environment variables for config & savefiles
export XDG_CONFIG_HOME="$CONFDIR"
export XDG_DATA_HOME="$CONFDIR"
#export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

cd $GAMEDIR

# Source love2d runtime
source $controlfolder/runtimes/"love_11.5"/love.txt

# Use the love runtime
$GPTOKEYB "$LOVE_GPTK" -c "./clockwind.gptk" &
pm_platform_helper "$LOVE_BINARY"
$LOVE_RUN gamedata

# Cleanup any running gptokeyb instances, and any platform specific stuff.
pm_finish
