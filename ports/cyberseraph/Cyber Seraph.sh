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
GAMEDIR="/$directory/ports/cyberseraph"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64
$ESUDO chmod +x $GAMEDIR/tools/splash

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/libs.aarch64:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Pack oggs into apk
if [ -n "$(ls ./gamedata/*.ogg 2>/dev/null)" ]; then
    mkdir -p ./assets
    mv ./gamedata/*.ogg ./assets/ 2>/dev/null
    pm_message "Moving .ogg files from ./gamedata to ./assets/"
    zip -r -0 ./cyberseraph.port ./assets/
    pm_message "Zipping contents to ./cyberseraph.port"
    rm -Rf ./assets/
    pm_message "Packing oggs complete"
fi

# Extract and patch file
if [ -f "./gamedata/data.win" ]; then
    $controlfolder/xdelta3 -d -s "./gamedata/data.win" "./gamedata/patch.xdelta3" "./gamedata/game.droid"
    [ $? -eq 0 ] && rm "./gamedata/data.win" || pm_message "Patching of data.win has failed"
    # Delete unneeded files
    rm -f gamedata/*.{dll,ini,exe}
fi

# Display loading splash
$ESUDO ./tools/splash "splash.png" 2000 &

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "cyberseraph.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c gmloader.json

# Cleanup
pm_finish
