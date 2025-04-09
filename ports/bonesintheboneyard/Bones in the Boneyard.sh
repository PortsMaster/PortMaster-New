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
GAMEDIR="/$directory/ports/bonesintheboneyard"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64
$ESUDO chmod +x $GAMEDIR/tools/splash

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/libs.aarch64:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Delete unneeded files and rename data.win
rm -f gamedata/*.{dll,exe}
[ -f "./gamedata/data.win" ] && mv gamedata/data.win gamedata/game.droid

# Display loading splash
$ESUDO ./tools/splash "splash.png" 2000 &

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "bonesintheboneyard.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c gmloader.json

# Cleanup
pm_finish
