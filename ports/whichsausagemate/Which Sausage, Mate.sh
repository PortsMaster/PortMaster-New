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

GAMEDIR="/$directory/ports/whichsausagemate"
cd "$GAMEDIR"

exec > "$GAMEDIR/log.txt" 2>&1

mkdir -p "$GAMEDIR/conf"
mkdir -p "$GAMEDIR/cache"
export XDG_DATA_HOME="$GAMEDIR/conf"
export XDG_CONFIG_HOME="$GAMEDIR/conf"

# The loader always reports 1280x720; the game picks its first-run font size from the panel
export WSM_DISPLAY_HEIGHT="$DISPLAY_HEIGHT"

# Bogodroid answers Unity's CPU topology queries from support_files; without them Unity sees one core
mkdir -p "$GAMEDIR/support_files"
cat /sys/devices/system/cpu/present > "$GAMEDIR/support_files/cpu_present.txt"
cat /sys/devices/system/cpu/possible > "$GAMEDIR/support_files/cpu_possible.txt"

chmod a+x "$GAMEDIR/unityloader"
pm_platform_helper "$GAMEDIR/unityloader"

"$GAMEDIR/unityloader" wsm.toml

pm_finish
