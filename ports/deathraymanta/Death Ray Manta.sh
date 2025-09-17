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
GAMEDIR="/$directory/ports/deathraymanta"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64

# Prepare game files
if [ -f ./assets/data.win ]; then
	# Apply a patch
	checksum=$(md5sum "./assets/data.win" | awk '{print $1}')
    
    # Checksum for the Itch.io version
    if [ "$checksum" = "fc5a8afda2de1223ff25ef6c2b904925" ]; then
        $ESUDO $controlfolder/xdelta3 -d -s "$GAMEDIR/assets/data.win" "$GAMEDIR/tools/itchdrm.xdelta" "$GAMEDIR/assets/game.droid"
        rm assets/data.win
        pm_message "Itch.io data.win has been patched."
        # Checksum for the Steam version
    elif [ "$checksum" = "4bcc427a704e13348d9bbd3070f0b24b" ]; then
        $ESUDO $controlfolder/xdelta3 -d -s "$GAMEDIR/assets/data.win" "$GAMEDIR/tools/steamdrm.xdelta" "$GAMEDIR/assets/game.droid"
        rm assets/data.win
        pm_message "Steam data.win has been patched."
    else
        pm_message "Error: MD5 checksum of data.win does not match any expected version."
	exit 1
    fi

    # Performance Patch: This will reduce visual fidelity
    if [ -f $GAMEDIR/performancepatch.txt ]; then
	$ESUDO $controlfolder/xdelta3 -d -s "$GAMEDIR/assets/game.droid" "$GAMEDIR/tools/performance.xdelta" "$GAMEDIR/assets/game2.droid"
	rm assets/game.droid
	mv assets/game2.droid assets/game.droid
	pm_message "Performance patch has been applied."
    fi

	# Delete all redundant files
	rm -rf "assets/Source Snapshot/"
	rm -f assets/*.{dll,exe,txt,png}
	# Zip all game files into the game.port
	zip -r -0 ./game.port ./assets/
	rm -Rf ./assets/
	mkdir -p saves
else    
        pm_message "Missing data.win in assets folder or game has been patched."
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" -c ./deathraymanta.gptk &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish