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
#export PORT_32BIT="N"
get_controls


$ESUDO chmod 666 /dev/tty0

GAMEDIR="/$directory/ports/labyrinthoflegendaryloot"
cd $GAMEDIR

export XDG_DATA_HOME="$GAMEDIR/conf"
export XDG_CONFIG_HOME="$GAMEDIR/conf"
#export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
mkdir -p "$XDG_DATA_HOME"

# Enable logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO chmod 666 /dev/uinput

# Source love2d runtime
source $controlfolder/runtimes/"love_11.5"/love.txt

# Use the love runtime
$GPTOKEYB "$LOVE_GPTK" -c "./labyrinthoflegendaryloot.gptk" &
pm_platform_helper "$LOVE_BINARY"
$LOVE_RUN  "./gamedata/LabyrinthOfLegendaryLoot-1.12.love"

# Cleanup any running gptokeyb instances, and any platform specific stuff.
pm_finish
