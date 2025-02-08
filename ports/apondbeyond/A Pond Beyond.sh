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
GAMEDIR="/$directory/ports/apondbeyond"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x $GAMEDIR/tools/splash
$ESUDO chmod +x $GAMEDIR/tools/xdelta
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

#Patch Game
# If "assets/data.win" exists and matches the checksum of the itch or steam versions
if [ -f "./assets/data.win" ]; then
    checksum=$(md5sum "./assets/data.win" | awk '{print $1}')
    
    # Checksum for the Itch version
    if [ "$checksum" = "157985e8b4a1439df32e3180e49296e2" ]; then
        $ESUDO $GAMEDIR/tools/xdelta3 -d -s assets/data.win -f ./tools/patch/apondbeyond.xdelta assets/game.droid && \
        rm assets/data.win
	rm -f "assets/place data.win here.txt"
	pm_message "Itch version of the game has been patched."
	echo "Itch version of the game has been patched."
	zip -r -0 game.port ./assets/
	rm -rf ./assets
	mkdir -p saves
	pm_message "assets zipped into game.port"
	echo "assets zipped into game.port."
    else
        pm_message "Error: MD5 checksum of data.win does not match any expected version."
	echo "Error: MD5 checksum of data.win does not match any expected version."
        exit 1
    fi
fi

# Display loading splash
if [ -f "$GAMEDIR/log.txt" ]; then
    [ "$CFW_NAME" == "muOS" ] && $ESUDO ./tools/splash "splash.png" 1 
    $ESUDO ./tools/splash "splash.png" 2000 &
fi

# Assign gptokeyb and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "./apondbeyond.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "gmloader.json"

# Cleanup
pm_finish
