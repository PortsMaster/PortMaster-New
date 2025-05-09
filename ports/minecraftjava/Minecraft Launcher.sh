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

GAMEDIR="/$directory/ports/minecraftjava"

export XDG_DATA_HOME="$GAMEDIR/saves" # allowing saving to the same path as the game
export XDG_CONFIG_HOME="$GAMEDIR/saves"

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CONFIG_HOME"
mkdir -p $GAMEDIR/logs

## Uncomment the following file to log the output, for debugging purpose
> "$GAMEDIR/Launcherlog.txt" && exec > >(tee "$GAMEDIR/Launcherlog.txt") 2>&1

cd $GAMEDIR
rm main.start

source $controlfolder/runtimes/love_11.5/love.txt
$GPTOKEYB "love.${DEVICE_ARCH}" -c "minecraft-launcher.gptk" &
pm_platform_helper "$LOVE_BINARY"
$LOVE_RUN "minecraft-launcher"
$GAMEDIR/main.start

pm_finish
