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
GAMEDIR=/$directory/ports/simutrans
CONFDIR="$GAMEDIR/conf/"
BINARY=simutrans
cd $GAMEDIR

# Enable logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Bind directories and XDG to portfolder
bind_directories ~/.config/$BINARY $GAMEDIR/conf
export XDG_DATA_HOME="$CONFDIR"

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTINTERACTIVE="Y"

# Run port
$GPTOKEYB "$BINARY.${DEVICE_ARCH}" -c "./$BINARY.gptk.$ANALOG_STICKS" &
pm_platform_helper "$GAMEDIR/$BINARY.${DEVICE_ARCH}"
./$BINARY.${DEVICE_ARCH} -use_hw -async
pm_finish
