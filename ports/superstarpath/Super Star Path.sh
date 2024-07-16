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

GAMEDIR="/$directory/ports/superstarpath"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$GAMEDIR/utils/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"

# We log the execution of the script into log.txt
exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Patch game
cd "$GAMEDIR"
# If "gamedata/game.unx" exists and its size is 911,688 bytes, apply the xdelta3 patch
if [ -f "./gamedata/game.unx" ]; then
    file_size=$(ls -l "./gamedata/game.unx" | awk '{print $5}')
    if [ "$file_size" -eq 911688 ]; then
        $ESUDO $controlfolder/xdelta3 -d -s gamedata/game.unx -f ./patch/game.xdelta gamedata/game.unx
    fi
fi

# If "gamedata/audiogroup1.dat" exists and its size is 3,204,899 bytes, apply the xdelta3 patch
if [ -f "./gamedata/audiogroup1.dat" ]; then
    file_size=$(ls -l "./gamedata/audiogroup1.dat" | awk '{print $5}')
    if [ "$file_size" -eq 3204899 ]; then
        $ESUDO $controlfolder/xdelta3 -d -s gamedata/audiogroup1.dat -f ./patch/audio1.xdelta gamedata/audiogroup1.dat
    fi
fi

# If "gamedata/audiogroup2.dat" exists and its size is 9,763,779 bytes, apply the xdelta3 patch
if [ -f "./gamedata/audiogroup2.dat" ]; then
    file_size=$(ls -l "./gamedata/audiogroup2.dat" | awk '{print $5}')
    if [ "$file_size" -eq 9763779 ]; then
        $ESUDO $controlfolder/xdelta3 -d -s gamedata/audiogroup2.dat -f ./patch/audio2.xdelta gamedata/audiogroup2.dat
    fi
fi

# We log the execution of the script into log.txt
exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

# Check for file existence before trying to manipulate them:
[ -f "./gamedata/data.unx" ] && mv gamedata/data.unx gamedata/game.droid
[ -f "./gamedata/game.unx" ] && mv gamedata/game.unx gamedata/game.droid

# Make sure uinput is accessible so we can make use of the gptokeyb controls
$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "gmloader" -c ./superstarpath.gptk &

$ESUDO chmod +x "$GAMEDIR/gmloader"

./gmloader superstarpath.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0

