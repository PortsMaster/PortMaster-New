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

GAMEDIR="/$directory/ports/discroom"

# Exports
export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=0
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_windows"
export TOOLDIR="$GAMEDIR/tools"
export PATH=$PATH:$TOOLDIR
export PATCHER_FILE="$GAMEDIR/patch/patchscript"
export PATCHER_GAME="Disc Room"
export PATCHER_TIME="3 to 5 minutes"
export PATCHDIR=$GAMEDIR

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Permissions
$ESUDO chmod +x "$GAMEDIR/gmloader"
$ESUDO chmod +x "$TOOLDIR/splash"

cd "$GAMEDIR"

# Run install if needed
if [ ! -f "$GAMEDIR/gamedata/game.droid" ]; then
    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb)
    else
        pm_message "This port requires the latest version of PortMaster."
    fi
else
    pm_message "Patching process already completed. Skipping."
fi

if [ ! -f "$GAMEDIR/gamedata/config.ini" ]; then
  mv "$GAMEDIR/config.ini.default" "$GAMEDIR/gamedata/config.ini"
fi

$GPTOKEYB "gmloader" &

pm_platform_helper "$GAMEDIR/gmloader"
./gmloader game.apk

pm_finish