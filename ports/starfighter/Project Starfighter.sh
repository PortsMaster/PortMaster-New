#!/bin/sh

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

#export PORT_32BIT="Y" # If using a 32 bit port
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR=/$directory/ports/starfighter/
CONFDIR="$GAMEDIR/conf/"

mkdir -p "$GAMEDIR/conf/.config/starfighter"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export XDG_DATA_HOME="$CONFDIR"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# if XDG Path does not work
# Use bind_directories to reroute that to a location within the ports folder.
bind_directories ~/.starfighter $GAMEDIR/conf/.config/starfighter 

pm_platform_helper "$GAMEDIR/starfighter"

$GPTOKEYB "starfighter" &
pm_platform_helper "$GAMEDIR/starfighter"
cd $GAMEDIR/share/starfighter
../../bin/starfighter

pm_finish
