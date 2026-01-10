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

GAMEDIR="/$directory/ports/xargon"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

cd $GAMEDIR

$ESUDO cp "$GAMEDIR/xrfile01.${DEVICE_ARCH}" "$GAMEDIR/xrfile01"

$ESUDO chmod +x "$GAMEDIR/xrfile01"
$ESUDO chmod +x "$GAMEDIR/7zzs.${DEVICE_ARCH}"
$ESUDO chmod ugo+rw "$GAMEDIR/config.xr1"

# Extract game files on 1st run
if [ ! -f "$GAMEDIR/tiles.xr1" ]; then
    "$GAMEDIR/7zzs.${DEVICE_ARCH}" x "$GAMEDIR/gamedata.7z" -o"$GAMEDIR/"
fi

$GPTOKEYB "xrfile01" -c "$GAMEDIR/xargon.gptk" &
pm_platform_helper "$GAMEDIR/xrfile01"
./xrfile01

pm_finish
