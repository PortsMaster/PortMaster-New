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

export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
export XDG_DATA_HOME="$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
cd $GAMEDIR

MP3FILES_COUNT=$(find ./mp3/*.mp3 -type f | wc -l)

if [ "$MP3FILES_COUNT" -gt "20" ]; then
        sed -E -i "s/^GameMusic\s*=\s*(false|true)$/GameMusic = true/" "$GAMEDIR/config.lua"
else
        sed -E -i "s/^GameMusic\s*=\s*(false|true)$/GameMusic = false/" "$GAMEDIR/config.lua"
fi

# $GPTOKEYB $BINARY -c "$BINARY.gptk" &
$GPTOKEYB2 $BINARY -c "$BINARY.gptk2" &
# ./$BINARY -console >$CUR_TTY <$CUR_TTY
pm_platform_helper "$GAMEDIR/$BINARY"
./$BINARY

pm_finish
