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

GAMEDIR="/$directory/ports/meanderland"

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x $GAMEDIR/tools/splash
$ESUDO chmod +x $GAMEDIR/tools/swapabxy.py
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64

export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TOOLDIR="$GAMEDIR/tools"
export PATH="$TOOLDIR:$PATH"

if [ ! -f "$GAMEDIR/meanderland.port" ]; then
    "$GAMEDIR/tools/7zzs" x "$GAMEDIR/gamedata.7z" -o"$GAMEDIR/"
    sleep 1
    rm -f "$GAMEDIR/gamedata.7z"
fi

swapabxy() {
  if [ "$CFW_NAME" == "knulli" ] && [ -f "$SDL_GAMECONTROLLERCONFIG_FILE" ]; then
    chmod +x "$TOOLDIR/swapabxy.py" < "$SDL_GAMECONTROLLERCONFIG_FILE" > "$GAMEDIR/gamecontrollerdb_swapped.txt"
    export SDL_GAMECONTROLLERCONFIG_FILE="$GAMEDIR/gamecontrollerdb_swapped.txt"
    export SDL_GAMECONTROLLERCONFIG="$(echo "$SDL_GAMECONTROLLERCONFIG" | "$TOOLDIR/swapabxy.py")"
  else
    echo "Warning: SDL_GAMECONTROLLERCONFIG_FILE is not set or does not exist."
  fi   
}

swapabxy  

[ "$CFW_NAME" == "muOS" ] && $ESUDO ./tools/splash "splash.png" 1 
$ESUDO ./tools/splash "splash.png" 2000 &

$GPTOKEYB "gmloadernext.aarch64" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "gmloader.json"

pm_finish
