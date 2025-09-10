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

GAMEDIR="/$directory/ports/alllcall"
GMLOADER_JSON="$GAMEDIR/gmloader.json"
TOOLDIR="$GAMEDIR/tools"

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO chmod +x "$GAMEDIR/gmloadernext.aarch64"
$ESUDO chmod +x "$GAMEDIR/tools/splash"
$ESUDO chmod +x $GAMEDIR/tools/SDL_swap_gpbuttons.py

if [ -f ./assets/data.win ]; then
	[ -f "./assets/data.win" ] && mv assets/data.win assets/game.droid
	zip -r -0 ./alllcall.port ./assets/
	rm -Rf ./assets/
fi

"$GAMEDIR/tools/SDL_swap_gpbuttons.py" -i "$SDL_GAMECONTROLLERCONFIG_FILE" -o "$GAMEDIR/gamecontrollerdb_swapped.txt" -l "$GAMEDIR/SDL_swap_gpbuttons.txt"
export SDL_GAMECONTROLLERCONFIG_FILE="$GAMEDIR/gamecontrollerdb_swapped.txt"
export SDL_GAMECONTROLLERCONFIG="`echo "$SDL_GAMECONTROLLERCONFIG" | "$GAMEDIR/tools/SDL_swap_gpbuttons.py" -l "$GAMEDIR/SDL_swap_gpbuttons.txt"`"

if [ ! -d ./assets ]; then
    $ESUDO "$GAMEDIR/tools/splash" "$GAMEDIR/splash.png" 4000 & 
fi

$GPTOKEYB "gmloadernext.aarch64" -c "./game.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

pm_finish