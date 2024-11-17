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

GAMEDIR="/$directory/ports/doomrl"
BINARY="drl"

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
export LD_LIBRARY_PATH="$GAMEDIR/libs:/usr/lib/:/usr/lib/aarch64-linux-gnu/:/usr/lib32/:$LD_LIBRARY_PATH"
export XDG_CONFIG_HOME="$GAMEDIR"
export XDG_DATA_HOME="$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
cd $GAMEDIR

MP3FILES_COUNT=$(find ./mp3/*.mp3 -type f | wc -l)

if [$MP3FILES_COUNT -gt 20]; then
	sed -e "s/^GameMusic\s*=\s*false$/GameMusic = true/" ./config.lua
else
	sed -e "s/^GameMusic\s*=\s*false$/GameMusic = false/" ./config.lua
fi

# $GPTOKEYB $BINARY -c "$BINARY.gptk" &
$GPTOKEYB2 $BINARY -c "$BINARY.gptk2" &
# ./$BINARY -console >$CUR_TTY <$CUR_TTY
pm_platform_helper "$GAMEDIR/$BINARY"
./$BINARY

pm_finish
