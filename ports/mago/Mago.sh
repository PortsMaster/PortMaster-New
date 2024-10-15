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

# PortMaster info
source "$controlfolder/control.txt"
get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

GAMEDIR=/$directory/ports/mago

# Enable logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$GAMEDIR/tools/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

export PATCHER_FILE="$GAMEDIR/patch/patchscript"
export PATCHER_GAME="MAGO"
export PATCHER_TIME="2 to 4 minutes"
export PATCHDIR=$GAMEDIR

# Permissions
$ESUDO chmod +x "$GAMEDIR/gmloadernext"
$ESUDO chmod +x "$GAMEDIR/patch/patchscript"
$ESUDO chmod +x "$GAMEDIR/tools/xdelta3"
$ESUDO chmod +x "$GAMEDIR/tools/splash"

cd "$GAMEDIR"

# Check if patchlog.txt exists to skip patching
if [ ! -f patchlog.txt ]; then
    source "$controlfolder/utils/patcher.txt"
fi

# Splash
$ESUDO ./tools/splash "splash.png" 5000 &

# GPTK Setup and run gmloader
$GPTOKEYB "gmloadernext" &
pm_platform_helper "$GAMEDIR/gmloadernext"
./gmloadernext game.apk

# Cleanup
pm_finish
printf "\033c" > /dev/tty0
