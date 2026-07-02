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
GAMEDIR="/$directory/ports/ninjasenkidx"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# CD and set permissions
cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="/usr/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64

# Extract the game files from the Steam release
if [ -f "$GAMEDIR/assets/NinjaSenkiDX.exe" ]; then
	# Use 7zip to extract the NinjaSenkiDX.exe to the destination directory
	"$controlfolder/7zzs.$DEVICE_ARCH" -aoa e "$GAMEDIR/assets/NinjaSenkiDX.exe" -o"$GAMEDIR/assets"
	# Apply a patch
	"$controlfolder/xdelta3" -d -s "$GAMEDIR/assets/data.win" -f "$GAMEDIR/tools/patchsenki.xdelta" "$GAMEDIR/assets/game.droid" 2>&1
	# Remove redundant files
	rm -f assets/*.{dll,win,exe}
	# Zip all game files into the ninjasenkidx.port and remove now needless assets folder
	zip -r -0 ./ninjasenkidx.port ./assets/
	rm -Rf ./assets/
	touch "install_completed"
fi

# Display loading splash
if [ -f install_completed ]; then
    $ESUDO "$GAMEDIR/tools/splash" "$GAMEDIR/splash.png" 4000 & 
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64"  &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish