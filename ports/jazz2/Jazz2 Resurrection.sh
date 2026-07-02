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
GAMEDIR="/$directory/ports/jazz2"
GAME="jazz2.${DEVICE_ARCH}"

# CD and set log
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
echo "entering $GAMEDIR"

# Ensure executable permissions
$ESUDO chmod -v +x "$GAMEDIR/$GAME"

# Exports
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export XDG_CONFIG_HOME="/$directory/ports"
export XDG_DATA_HOME="/$directory/ports"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"

# Launch the game
$GPTOKEYB2 "$GAME" &>/dev/null &
pm_platform_helper "$GAME"
echo "launching $GAME"
"./$GAME"

# Cleanup
pm_finish
