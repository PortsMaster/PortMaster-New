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
GAMEDIR="/$directory/ports/savingprincess"
GMLOADER_JSON="$GAMEDIR/gmloader.json"
TOOLDIR="$GAMEDIR/tools"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Ensure executable permissions
$ESUDO chmod +x "$GAMEDIR/gmloadernext.aarch64"
$ESUDO chmod +x "$GAMEDIR/tools/splash"

# Create saves directory
mkdir -p "$GAMEDIR/saves"

# Prepare game files and patch game
XDELTA_FILE=""

# Extract full game
if [ -f "$GAMEDIR/assets/Saving Princess.exe" ]; then
    actual_checksum=$(md5sum "$GAMEDIR/assets/Saving Princess.exe" | awk '{print $1}')

    if [ "$actual_checksum" = "35a111d0149fae1f04b7b3fea42c5319" ]; then
        "$controlfolder/7zzs.${DEVICE_ARCH}" x "$GAMEDIR/assets/Saving Princess.exe" -o"$GAMEDIR/assets" & pid=$!
        wait $pid
        XDELTA_FILE="$TOOLDIR/fullgame.xdelta"
    else
        pm_message "Error: MD5 checksum of Saving Princess.exe does not match the expected checksum."
    fi
fi

# Extract demo
if [ -f "$GAMEDIR/assets/Saving Princess - DEMO - Windows.exe" ]; then
    actual_checksum_demo=$(md5sum "$GAMEDIR/assets/Saving Princess - DEMO - Windows.exe" | awk '{print $1}')

    if [ "$actual_checksum_demo" = "26f6e1a57b1ed89a7554ced8bd58f2bb" ]; then
        "$controlfolder/7zzs.${DEVICE_ARCH}" x "$GAMEDIR/assets/Saving Princess - DEMO - Windows.exe" -o"$GAMEDIR/assets" & pid=$!
        wait $pid
        XDELTA_FILE="$TOOLDIR/demo.xdelta"
    else
        pm_message "Error: MD5 checksum of Saving Princess - DEMO - Windows.exe does not match the expected checksum."
    fi
fi

# Patch data.win and package game files
if [ -f "$GAMEDIR/assets/data.win" ]; then
    # Apply the appropriate xdelta patch
    $controlfolder/xdelta3 -d -s "$GAMEDIR/assets/data.win" "$XDELTA_FILE" "$GAMEDIR/assets/game.droid"
    # Delete all redundant files
    rm -f assets/*.{exe,dll,win,gitkeep}
    # Zip all game files into game.port
    zip -r -0 ./game.port ./assets/
    rm -rf ./assets/
fi

# Display loading splash
if [ ! -d ./assets ]; then
    $ESUDO "$GAMEDIR/tools/splash" "$GAMEDIR/splash.png" 4000 &
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "savingprincess.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish
