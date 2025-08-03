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

GAMEDIR="/$directory/ports/emojimerge"

export XDG_DATA_HOME="$GAMEDIR/conf" # allowing saving to the same path as the game
export XDG_CONFIG_HOME="$GAMEDIR/conf"
#export LD_LIBRARY_PATH="$GAMEDIR/libs.$DEVICE_ARCH:$LD_LIBRARY_PATH"

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CONFIG_HOME"

# Enable logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

LAUNCH_FILE="emojimerge.love"

$ESUDO chmod 666 /dev/uinput

# Source love2d runtime
source $controlfolder/runtimes/"love_11.5"/love.txt

# Use the love runtime
$GPTOKEYB "$LOVE_GPTK" -c "emojimerge.gptk" &
pm_platform_helper "$LOVE_BINARY"
$LOVE_RUN $LAUNCH_FILE

# Cleanup any running gptokeyb instances, and any platform specific stuff.
pm_finish