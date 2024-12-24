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
GAMEDIR="/$directory/ports/zeroptianinvasion"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x -R $GAMEDIR/*

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"

data_win="./gamedata/data.win"

# Check if the data.win file exists
if [ -f "$data_win" ]; then
    current_md5=$(md5sum "$data_win" | awk '{print $1}')
    # itch.io patch
    if [ "$current_md5" == "f0e0952c79e50d261993cfbf8731410f" ]; then
        $controlfolder/xdelta3 -d -s "$data_win" "./gamedata/patch_itch.xdelta3" "./gamedata/game.droid"
    # Steam patch
    elif [ "$current_md5" == "5b34b1f0a90a3ffb044c1016245d3eb6" ]; then
        $controlfolder/xdelta3 -d -s "$data_win" "./gamedata/patch_steam.xdelta3" "./gamedata/game.droid"
    else
        echo "MD5 checksum does not match any expected value. Aborting patch."
    fi
    # Delete unnecessary files
    rm -f gamedata/*.exe
    rm -f gamedata/options.ini
else
    echo "File $file_path does not exist."
fi

# Display loading splash
if [ -f "$GAMEDIR/gamedata/game.droid" ]; then
[ "$CFW_NAME" == "muOS" ] && $ESUDO ./tools/splash "splash.png" 1 # muOS only workaround
    $ESUDO ./tools/splash "splash.png" 2000
fi

# Run the game
$GPTOKEYB "gmloadernext" -c "./zeroptianinvasion.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext"
./gmloadernext

# Kill processes
pm_finish
