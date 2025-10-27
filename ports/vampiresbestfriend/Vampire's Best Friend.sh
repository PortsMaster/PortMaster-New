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
GAMEDIR="/$directory/ports/vampiresbestfriend"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

[ -f "./assets/Vampire's Best Friend Demo.exe" ] && mv "assets/Vampire's Best Friend Demo.exe" "assets/Vampire's Best Friend.exe"

if [ -f "$GAMEDIR/assets/Vampire's Best Friend.exe" ]; then
    # Use 7zip to extract the exe file to the destination directory
    "$GAMEDIR/tools/7zzs" -aos x "$GAMEDIR/assets/Vampire's Best Friend.exe" -o"$GAMEDIR/assets"
 	# Rename data.win file
	mv assets/data.win assets/game.droid
	# Delete all redundant files
	rm -f assets/*.{exe,dll}
	# Zip all game files into the vampirebestfriend.port
	zip -r -0 ./vampirebestfriend.port ./assets/
	rm -Rf ./assets/
fi

# Display loading splash
if [ -f "$GAMEDIR/log.txt" ]; then
    [ "$CFW_NAME" == "muOS" ] && $ESUDO ./tools/splash "splash.png" 1
    $ESUDO ./tools/splash "splash.png" 5000 & 
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "vampirebestfriend.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish