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

export controlfolder

source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# Variables
GAMEDIR="/$directory/ports/cosmicwheel"

# CD and set up logging
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/lib:$LD_LIBRARY_PATH"
$ESUDO chmod +x "$GAMEDIR/gmloadernext.aarch64"

# Check if the patching needs to be applied
check_patch() {
	if [ ! -f "$GAMEDIR/patchlog.txt" ] && [ -f "$GAMEDIR/assets/data.win" ]; then
		if [ -f "$controlfolder/utils/patcher.txt" ]; then
			set -o pipefail
			
			# Setup mono environment variables
			DOTNETDIR="$HOME/mono"
			DOTNETFILE="$controlfolder/libs/dotnet-8.0.12.squashfs"
			$ESUDO mkdir -p "$DOTNETDIR"
			$ESUDO umount "$DOTNETFILE" || true
			$ESUDO mount "$DOTNETFILE" "$DOTNETDIR"
			export PATH="$DOTNETDIR":"$PATH"
			
			# Setup and execute the Portmaster Patcher utility with our patch file
			export ESUDO
			export DEVICE_RAM
			export PATCHER_FILE="$GAMEDIR/tools/patchscript"
			export PATCHER_GAME="$(basename "${0%.*}")"
			export PATCHER_TIME="10-15 minutes"
			source "$controlfolder/utils/patcher.txt"
			$ESUDO umount "$DOTNETDIR"
		else
			pm_message "This port requires the latest version of PortMaster."
			pm_finish
			exit 1
		fi
	fi
}

# Check if we need to start the external patcher as it is not needed on devices with enough RAM
if [[ "$DEVICE_RAM" -ge 5 ]] && [ -f "$GAMEDIR/assets/data.win" ]; then 
    # get data.win checksum for the full version
    checksum=$(md5sum "assets/data.win" | awk '{ print $1 }')
		# # Checksum for the full versio
		if [ "$checksum" == "75727dd02f24207b46fe676aec02a22c" ]; then
		# Patch for screen scaling
		$controlfolder/xdelta3 -d -s "$GAMEDIR/assets/data.win" -f "$GAMEDIR/tools/patch.xdelta" "$GAMEDIR/assets/game.droid" 2>&1
		echo "Data.win file for the full version has been patched"
	else
	    # Rename data.win file
	    mv assets/data.win assets/game.droid
	fi
	# Delete all redundant files
	rm -f assets/*.{exe,dll,win}
	# Zip all game files into the cosmicwheel.port
	zip -r -0 ./cosmicwheel.port ./assets/
	rm -Rf ./assets/
else
	check_patch
fi

# Prevent Rocknix from reseting the position of the mouse cursor
swaymsg seat seat0 hide_cursor 0

# Assign gptokeyb and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "cosmicwheel.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64" >/dev/null
./gmloadernext.aarch64 -c gmloader.json


# Kill processes
pm_finish

# Now the default mouse behaviour can be restored
swaymsg seat seat0 hide_cursor 1000