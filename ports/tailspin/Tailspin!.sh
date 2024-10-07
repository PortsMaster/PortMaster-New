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

get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

# Variables
GAMEDIR="/$directory/ports/tailspin"
TOOLDIR="$GAMEDIR/tools"

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export PATH="$TOOLDIR:$PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_PLATFORM="os_linux"

cd $GAMEDIR

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Make sure uinput is accessible so we can make use of the gptokeyb controls
$ESUDO chmod 777 "$GAMEDIR/gmloadernext"

# Splash
$ESUDO ./tools/splash "splash.png" 10000 &

$GPTOKEYB "gmloadernext" -c ./controls.gptk &
pm_platform_helper $GAMEDIR/gmloadernext
$ESUDO chmod +x "$GAMEDIR/gmloadernext"

./gmloadernext game.apk

pm_finish
printf "\033c" > /dev/tty0
