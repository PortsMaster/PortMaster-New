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
source $controlfolder/device_info.txt
export PORT_32BIT="Y"

get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

$ESUDO chmod 666 /dev/tty0

GAMEDIR="/$directory/ports/vitasnake"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/vitasnake/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/vitasnake/gamedata/"
export GMLOADER_PLATFORM="os_linux"

# We log the execution of the script into log.txt
"$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

# Check for file existence before trying to manipulate them:
[ -f "./vitasnake/gamedata/data.win" ] && mv vitasnake/gamedata/data.win vitasnake/gamedata/game.droid
[ -f "./vitasnake/gamedata/game.win" ] && mv vitasnake/gamedata/game.win vitasnake/gamedata/game.droid
[ -f "./vitasnake/gamedata/game.unx" ] && mv vitasnake/gamedata/game.unx vitasnake/gamedata/game.droid

# Make sure uinput is accessible so we can make use of the gptokeyb controls
$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "gmloader" -c ./vitasnake/controls.gptk &

$ESUDO chmod +x "$GAMEDIR/vitasnake/gmloader"

./vitasnake/gmloader vitasnake/game.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
