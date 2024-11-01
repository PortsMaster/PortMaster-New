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

printf "\033c" > $CUR_TTY
printf "Starting game (first load can take a while)...\n" > $CUR_TTY

$GPTOKEYB $BINARY -c "$BINARY.gptk" &
# ./$BINARY -console >$CUR_TTY <$CUR_TTY
./$BINARY

pm_finish
printf "\033c" > $CUR_TTY
