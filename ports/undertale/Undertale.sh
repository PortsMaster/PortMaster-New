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
GAMEDIR="/$directory/ports/undertale"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +xwr "$GAMEDIR/gmloadernext.aarch64"

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

add_mod() {
    output=$("$controlfolder/xdelta3" -d -s "$GAMEDIR/assets/data.win" -f "$GAMEDIR/mod/borders_steam.xdelta" "$DATADIR/game.droid" 2>&1)
    if [ $? -eq 0 ]; then
        echo "Patch applied successfully"
        echo "$output"
        rm "$DATADIR/data.win"
    else
        echo "Unable to apply borders mod: $output"
    fi
}

# Check for linux Undertale version
[ -f "./assets/game.unx" ] && mv assets/game.unx assets/data.win

# Apply PS4 borders mod if 1920x1080 resolution
if [ "$DISPLAY_WIDTH" = "1920" ] && [ "$DISPLAY_HEIGHT" = "1080" ]; then
    FILESUM=$(md5sum "$DATADIR/data.win" | awk '{ print $1 }')
    STEAMSUM="5903fc5cb042a728d4ad8ee9e949c6eb"

    if [ "$FILESUM" = "$STEAMSUM" ]; then
        add_mod
    fi
fi

# Prepare game files
if [ -f ./assets/data.win ]; then
	# Rename data.win file
	mv assets/data.win assets/game.droid
	# Delete all redundant files
	rm -f assets/*.{dll,exe,txt}
	# Zip all game files into the undertale.port
	zip -r -0 ./undertale.port ./assets/
	rm -Rf ./assets/
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "undertale.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish