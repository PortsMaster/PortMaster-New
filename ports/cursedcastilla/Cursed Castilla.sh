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

export controlfolder

source $controlfolder/control.txt

export PORT_32BIT="Y" # If using a 32 bit port
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR=/$directory/ports/cursedcastilla/

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/saves/"
export GMLOADER_PLATFORM="os_windows"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO chmod +x "$GAMEDIR/gmloader"

# Prepare game files
if [ -f ./assets/data.win ]; then
	# Apply a patch to fix scaling
	$controlfolder/xdelta3 -d -s "assets/data.win" "tools/patch.xdelta" "assets/game.droid" && rm "assets/data.win"
	# Delete all redundant files
	rm -f assets/*.{exe,dll}
	# Zip all game files into the cursedcastilla.port
	zip -r -0 ./cursedcastilla.port ./assets/
	rm -Rf ./assets/
fi

$GPTOKEYB "gmloader" -c ./cursedcastilla.gptk &
pm_platform_helper "gmloader"
LD_PRELOAD="$PWD/hacksdl.so" HACKSDL_DEVICE_DISABLE_0=1 ./gmloader cursedcastilla.port

pm_finish