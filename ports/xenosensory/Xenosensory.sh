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
GAMEDIR="/$directory/ports/xenosensory"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x $GAMEDIR/gmlnext.aarch64

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Prepare game files
if [ -f ./assets/data.win ]; then
	# Rename data.win file
	mv assets/data.win assets/game.droid
	# Delete all redundant files
	rm -f assets/*.{exe,dll}
	# Zip all game files into the xenosensory.port
	zip -r -0 ./xenosensory.port ./assets/
	rm -Rf ./assets/
fi

# Adjust mouse deadzone_scale based on resolution width
if [ "$DISPLAY_WIDTH" -lt 1280 ]; then
    echo "Setting deadzone_scale to 8"
    sed -i 's/^[[:space:]]*deadzone_scale[[:space:]]*=.*/deadzone_scale = 8/' controls.ini
elif [ "$DISPLAY_WIDTH" -lt 1920 ]; then
    echo "Setting deadzone_scale to 13"
    sed -i 's/^[[:space:]]*deadzone_scale[[:space:]]*=.*/deadzone_scale = 13/' controls.ini
else
    echo "Setting deadzone_scale to 18"
    sed -i 's/^[[:space:]]*deadzone_scale[[:space:]]*=.*/deadzone_scale = 20/' controls.ini
fi


# Stop Rocknix from messing with mouse cursor
if [ "$CFW_NAME" = "ROCKNIX" ]; then
    swaymsg seat seat0 hide_cursor 0
fi


# Assign configs and load the game
$GPTOKEYB2 "gmlnext.aarch64" -c "controls.ini" &
pm_platform_helper "$GAMEDIR/gmlnext.aarch64"
./gmlnext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish

# Cursor shenanigans can be resumed
if [[ ${CFW_NAME} == ROCKNIX ]]; then
  swaymsg "$(swaymsg -t get_config -p | grep hide_cursor)"
fi