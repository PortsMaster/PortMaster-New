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

# Variables
GAMEDIR="/$directory/ports/idlebreakout"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# CD and set log
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Ensure executable permissions
$ESUDO chmod +x "$GAMEDIR/gmloadernext.aarch64"

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Prepare game files
if [ -f "$GAMEDIR/assets/IdleBreakout.exe" ]; then
    "$controlfolder/7zzs.$DEVICE_ARCH" -aos x "$GAMEDIR/assets/IdleBreakout.exe" -o"$GAMEDIR/assets" 
fi

# Prepare game files
if [ -f ./assets/data.win ]; then
	# Rename data.win
	mv assets/data.win assets/game.droid
	# Delete all redundant files
	rm -f assets/*.{dll,exe,txt}
	# Zip all game files into the idlebreakout.port
	zip -r -0 ./idlebreakout.port ./assets/
	rm -Rf ./assets/
fi

if [ "$CFW_NAME" = "ROCKNIX" ]; then
  export SDL_TOUCH_MOUSE_EVENTS=0
  swaymsg input type:touch events disabled 2>/dev/null
  swaymsg seat '*' hide_cursor 0 2>/dev/null
  trap 'swaymsg seat "*" hide_cursor 1000 2>/dev/null' EXIT
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "idlebreakout.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
LD_PRELOAD="$GAMEDIR/libs/sdl_cursor.so" ./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish
