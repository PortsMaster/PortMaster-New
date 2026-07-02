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
GAMEDIR="/$directory/ports/powerlevel"
GMLOADER_JSON="$GAMEDIR/gmloader.json"
TOOLDIR="$GAMEDIR/tools"
SAVEDIR="$GAMEDIR/saves"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Ensure executable permissions
$ESUDO chmod +x "$GAMEDIR/gmloadernext.aarch64"
$ESUDO chmod +x "$GAMEDIR/tools/splash"

# Extract the contents of Power Level v1.2.zip
if [ -f "./assets/Power Level v1.2.zip" ]; then
    $controlfolder/7zzs.${DEVICE_ARCH} x "./assets/Power Level v1.2.zip" -o./assets
    rm -f "./assets/Power Level v1.2.zip" \
          "./assets/place Power Level v1.2.zip here"
fi

# Prepare game files
if [ -f ./assets/data.win ]; then
    mkdir -p "$SAVEDIR"
    # Copy Directories and Files
    [ -d "./assets/Fonts" ] && cp -r "./assets/Fonts" "$SAVEDIR/"
    # Apply a patch
    $controlfolder/xdelta3 -d -s "$GAMEDIR/assets/data.win" "$TOOLDIR/powerlevel.xdelta" "$GAMEDIR/assets/game.droid"
    # Delete all redundant files
    rm -f assets/*.{exe,dll}
    # Zip all game files into the game.port
    zip -r -0 ./game.port ./assets/
    rm -Rf ./assets/
fi

# Display loading splash
if [ ! -d ./assets ]; then
    $ESUDO "$GAMEDIR/tools/splash" "$GAMEDIR/splash.png" 4000 & 
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "powerlevel.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish