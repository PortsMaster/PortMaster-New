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

get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

GAMEDIR="/$directory/ports/itta"

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x -R $GAMEDIR/*
$ESUDO chmod +x "$TOOLDIR/xdelta3"

cd "$GAMEDIR"

# Exports
export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_windows"
export TOOLDIR="$GAMEDIR/tools"
export PATH=$PATH:$TOOLDIR
export PATCHER_FILE="$GAMEDIR/patch/patchscript"
export PATCHER_GAME="ITTA"
export PATCHER_TIME="15 to 20 minutes"
export PATCHDIR=$GAMEDIR

# dos2unix in case we need it
dos2unix "$GAMEDIR/tools/gmKtool.py"
dos2unix "$GAMEDIR/tools/Klib/GMblob.py"
dos2unix "$GAMEDIR/patch/patchscript"

# Run install if needed
if [ ! -f "$GAMEDIR/gamedata/game.droid" ]; then
    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb)
    else
        echo "This port requires the latest version of PortMaster." > $CUR_TTY
    fi
else
    echo "Patching process already completed. Skipping."
fi

$GPTOKEYB "gmloader" &

pm_platform_helper "$GAMEDIR/gmloader"
./gmloader itta.apk

pm_finish