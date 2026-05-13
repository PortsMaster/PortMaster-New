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
GAMEDIR="/$directory/ports/leadhaul"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x -R $GAMEDIR/*

# Exports
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/tools/lib:$LD_LIBRARY_PATH"
export controlfolder

# Config
mkdir -p "$GAMEDIR/save"
bind_directories "$XDG_DATA_HOME/love/Lead hall/savegames" "$GAMEDIR/save"
source $controlfolder/runtimes/"love_11.5"/love.txt

# Run the love runtime
$GPTOKEYB "$LOVE_GPTK" -c "./leadhaul.gptk" &
pm_platform_helper "$LOVE_BINARY"
$LOVE_RUN "$GAMEDIR/leadhaul.love"

pm_finish
