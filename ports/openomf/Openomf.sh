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

GAMEDIR="/$directory/ports/openomf"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

bind_directories ~/.local/share/openomfproject $GAMEDIR/conf/openomfproject

$ESUDO chmod +x "$GAMEDIR/openomf.${DEVICE_ARCH}"

export OPENOMF_RESOURCE_DIR="$GAMEDIR/gamedata"
export OPENOMF_PLUGIN_DIR="$GAMEDIR/plugins"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"

$GPTOKEYB "openomf.${DEVICE_ARCH}" -c "$GAMEDIR/openomf.gptk" &
pm_platform_helper "$GAMEDIR/openomf.${DEVICE_ARCH}"
./openomf.${DEVICE_ARCH}

pm_finish
