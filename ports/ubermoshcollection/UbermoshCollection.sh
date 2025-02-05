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
export PORT_32BIT="Y"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

export GAMEDIR="/$directory/ports/Uber"

export DEVICE_ARCH="${DEVICE_ARCH:-armhf}"
export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/gamedata/lib:$LD_LIBRARY_PATH"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

$GPTOKEYB "gameselector.armhf" -c "$GAMEDIR/gameselector.gptk" &
pm_message "Loading, please wait... " > /dev/tty0

$ESUDO chmod +x "$GAMEDIR/gameselector.armhf"
$ESUDO chmod +x "$GAMEDIR/gamedata/black.run"
$ESUDO chmod +x "$GAMEDIR/gamedata/ubermosh.run"
$ESUDO chmod +x "$GAMEDIR/gamedata/omega.run"
$ESUDO chmod +x "$GAMEDIR/gamedata/santicide.run"
$ESUDO chmod +x "$GAMEDIR/gamedata/vol3.run"
$ESUDO chmod +x "$GAMEDIR/gamedata/vol5.run"
$ESUDO chmod +x "$GAMEDIR/gamedata/vol7.run"
$ESUDO chmod +x "$GAMEDIR/gamedata/wraith.run"

$ESUDO chmod +x "$GAMEDIR/gamedata/black/gmloader"
$ESUDO chmod +x "$GAMEDIR/gamedata/ubermosh/gmloader"
$ESUDO chmod +x "$GAMEDIR/gamedata/omega/gmloader"
$ESUDO chmod +x "$GAMEDIR/gamedata/santicide/gmloader"
$ESUDO chmod +x "$GAMEDIR/gamedata/vol3/gmloader"
$ESUDO chmod +x "$GAMEDIR/gamedata/vol5/gmloader"
$ESUDO chmod +x "$GAMEDIR/gamedata/vol7/gmloader"
$ESUDO chmod +x "$GAMEDIR/gamedata/wraith/gmloader"

pm_platform_helper "$GAMEDIR/gameselector.armhf"
./gameselector.armhf

pm_finish
