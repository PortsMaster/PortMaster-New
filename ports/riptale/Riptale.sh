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

GAMEDIR="/$directory/ports/riptale"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_linux"

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

# Rename game.unx to game.droid if it exists in ./gamedata
if [ -e "./gamedata/game.unx" ]; then
    mv ./gamedata/game.unx ./gamedata/game.droid || exit 1
elif [ -e "./gamedata/data.win" ]; then
    mv ./gamedata/data.win ./gamedata/game.droid || exit 1
fi

# Make sure uinput is accessible so we can make use of the gptokeyb controls
$ESUDO chmod 666 /dev/uinput

$ESUDO chmod +x "$GAMEDIR/gmloader"

#Exctract initial custom config so it defaults to D-Pad for input
[ ! -f "$GAMEDIR/gamedata/options_data.ini" ] && unzip -o "$GAMEDIR/gamedata/options_data.zip" -d "$GAMEDIR/gamedata/"

if [ $ANALOG_STICKS == '0' ]; then
    GPTOKEYB_CONFIG="-c $GAMEDIR/riptale.gptk"
else
    GPTOKEYB_CONFIG="xbox360"
fi

$GPTOKEYB "gmloader" $GPTOKEYB_CONFIG &

./gmloader riptale.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
