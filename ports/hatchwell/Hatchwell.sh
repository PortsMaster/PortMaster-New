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
GAMEDIR="/$directory/ports/hatchwell"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x -R $GAMEDIR/*

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"

# Patch game
cd "$GAMEDIR"

# If "gamedata/data.win" exists and matches the checksum of the steam versions
if [ -f "./gamedata/data.win" ]; then
    checksum=$(md5sum "./gamedata/data.win" | awk '{print $1}')
    
    # Checksum for the Steam version
    if [ "$checksum" = "8584c4d3227e3219c9ac6db2ca3ff162" ]; then
        $ESUDO ./patch/xdelta3 -d -s gamedata/data.win -f ./patch/hatchwell.xdelta gamedata/game.droid && \
        rm gamedata/data.win
    else
        echo "Error: MD5 checksum of data.win does not match any expected version."
	exit 1
    fi
else    
    echo "Error: Missing files in gamedata folder or game has been patched."
fi

# Check if either "Hatchwell.exe"exists
if [ -f "./gamedata/Hatchwell.exe" ]; then    
    # Remove extra files from Steam or Itch.io builds
    rm -Rf "./gamedata/Hatchwell.exe" \
           "./gamedata/"*.dll \
	   "./gamedata/Place game files here" 
    echo "Extra game files removed"
else    
    echo "No extra game files to remove"
fi

# Display loading splash
if [ -f "$GAMEDIR/gamedata/game.droid" ]; then
[ "$CFW_NAME" == "muOS" ] && $ESUDO ./lib/splash "splash.png" 1 # muOS only workaround
    $ESUDO ./lib/splash "splash.png" 2000
fi

# Run the game
$GPTOKEYB "gmloadernext" -c "./hatchwell.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext"
./gmloadernext

# Kill processes
pm_finish
