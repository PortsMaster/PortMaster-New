#!/bin/bash

# Source PortMaster control & device variables via pm_helper
# https://portmaster.games/packaging.html
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

source "$controlfolder/control.txt"
export PORT_32BIT="Y"

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# Set game directory and log output
GAMEDIR="/$directory/ports/ultionus"
cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Export environment variables for GMLoader
export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_windows"

# Asset conversion / renaming check
[ -f "./gamedata/data.win" ] && mv ./gamedata/data.win ./gamedata/game.droid
[ -f "./gamedata/game.win" ] && mv ./gamedata/game.win ./gamedata/game.droid
[ -f "./gamedata/assets/game.unx" ] && mv ./gamedata/assets/game.unx ./gamedata/game.droid

# Pack audio into apk if not done yet
if [ -n "$(ls ./gamedata/*.ogg 2>/dev/null)" ]; then
    mkdir -p ./assets
    mv ./gamedata/*.ogg ./assets/
    echo "Moved .ogg files from ./gamedata to ./assets/"

    # Zip audio assets into APK
    zip -r -0 ./ultionus.apk ./assets/
    echo "Zipped contents to ./ultionus.apk"
    rm -rf "$GAMEDIR/assets/"

    # Cleanup extra files if copied from Steam
    rm -rf "$GAMEDIR/gamedata/Ultionus.exe"
fi

# Prepare executable & gptokeyb controls
$GPTOKEYB "gmloader" &
$ESUDO chmod +x "$GAMEDIR/gmloader"

# Launch Game
./gmloader ultionus.apk

# Standard PortMaster cleanup function (handles killing gptokeyb, clearing video, restoring system states)
pm_finish