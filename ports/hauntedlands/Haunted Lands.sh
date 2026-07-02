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
GAMEDIR="/$directory/ports/hauntedlands"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# CD and set up logging
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="/usr/lib:$LD_LIBRARY_PATH"
$ESUDO chmod +x "$GAMEDIR/gmloadernext.aarch64"

# Check for the original Alpha Episode
if [ -f ./assets/Haunted_Lands_EA.exe ]; then
	# Use 7zip to extract the Haunted_Lands_EA.exe to the destination directory
	"$controlfolder/7zzs.$DEVICE_ARCH" -aoa e "$GAMEDIR/assets/Haunted_Lands_EA.exe" -x!*.exe -o"$GAMEDIR/assets"
	# Set gmloader.json to Episode Alpha port file
	sed -i 's|"apk_path" : "hauntedlands.port"|"apk_path" : "hauntedlandsea.port"|' $GMLOADER_JSON
	# Rename data.win
	mv assets/data.win assets/game.droid
	# Delete all redundant files
	rm -f assets/*.{dll,exe,txt}
	# Zip all game files into the hauntedlandsea.port
	zip -r -0 ./hauntedlandsea.port ./assets/
	rm -Rf ./assets/ 
	touch "$GAMEDIR/ea_version.txt"
fi

# Check if the patching needs to be applied (retail only)
if [ ! -f "$GAMEDIR/ea_version.txt" ] && [ ! -f "$GAMEDIR/patchlog.txt" ] && [ -f "$GAMEDIR/assets/data.win" ]; then
	if [ -f "$controlfolder/utils/patcher.txt" ]; then
		set -o pipefail
		export ESUDO
		export controlfolder
		export PATCHER_FILE="$GAMEDIR/tools/patchscript"
		export PATCHER_GAME="$(basename "${0%.*}")"
		export PATCHER_TIME="5 minutes"
		source "$controlfolder/utils/patcher.txt"
		$ESUDO umount "$DOTNETDIR"
	else
		pm_message "This port requires the latest version of PortMaster."
		pm_finish
		exit 1
	fi
fi

# Assign gptokeyb and load the game
if [ -f "$GAMEDIR/ea_version.txt" ]; then
	$GPTOKEYB "gmloadernext.aarch64" -c "hauntedlandsea.gptk" &
else
	$GPTOKEYB "gmloadernext.aarch64" &
fi

pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c gmloader.json


# Kill processes
pm_finish
