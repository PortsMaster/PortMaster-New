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
GAMEDIR="/$directory/ports/orcishskies"
TOOLDIR="$GAMEDIR/tools"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
$ESUDO chmod +x $GAMEDIR/gmloadernext.${DEVICE_ARCH}

# Check for the demo version to set a correct port file
if [ -f ./assets/data.win ]; then
	# get data.win checksum
	checksum=$(md5sum "assets/data.win" | awk '{ print $1 }')
	
	# Check for Steam demo version
	if [ "$checksum" == "7e492ec02545a8c4735de70a361478e9" ]; then
		sed -i 's|"apk_path" : "orcishskies.port"|"apk_path" : "orcishskiesdemo.port"|' $GMLOADER_JSON
		sed -i 's|export DATAFILE="orcishskies.port"|export DATAFILE="orcishskiesdemo.port"|' $TOOLDIR/patchscript
	fi
fi


# Adjust dpad_mouse_step, deadzone_scale and mouse delay based on resolution width
if [ "$DISPLAY_WIDTH" -lt 1280 ]; then
    echo "Setting dpad_mouse_step and deadzone_scale to 4 and mouse_delay to 8"
    sed -i -E 's/(dpad_mouse_step|deadzone_scale) = [0-9]/\1 = 4/g' orcishskies.gptk
	sed -i -E 's/(mouse_delay) = [0-9]/\1 = 9/g' orcishskies.gptk
elif [ "$DISPLAY_WIDTH" -lt 1920 ]; then
    echo "Setting dpad_mouse_step and deadzone_scale to 3, and mouse_delay to 4"
    sed -i -E 's/(dpad_mouse_step|deadzone_scale) = [0-9]/\1 = 3/g' orcishskies.gptk
	sed -i -E 's/(mouse_delay) = [0-9]/\1 = 4/g' orcishskies.gptk
else
    echo "Setting dpad_mouse_step and deadzone_scale to 7, and mouse_delay to 4"
    sed -i -E 's/(dpad_mouse_step|deadzone_scale) = [0-9]/\1 = 7/g' orcishskies.gptk
	sed -i -E 's/(mouse_delay) = [0-9]/\1 = 4/g' orcishskies.gptk
fi

# Check if the patching needs to be applied
if [ ! -f "$GAMEDIR/patchlog.txt" ] && [ -f "$GAMEDIR/assets/data.win" ]; then
	if [ -f "$controlfolder/utils/patcher.txt" ]; then
		set -o pipefail
		
		# Setup and execute the Portmaster Patcher utility with our patch file
		export controlfolder
		export ESUDO
		export PATCHER_FILE="$GAMEDIR/tools/patchscript"
		export PATCHER_GAME="$(basename "${0%.*}")"
		export PATCHER_TIME="10 minutes"
		source "$controlfolder/utils/patcher.txt"
	else
		pm_message "This port requires the latest version of PortMaster."
		pm_finish
		exit 1
	fi
fi

# Disable cursor auto-hide if on Rocknix
if [[ ${CFW_NAME} == ROCKNIX ]]; then
  swaymsg 'seat * hide_cursor 0'
  NOHIDING=true
fi


 
# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "orcishskies.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
LD_PRELOAD="$GAMEDIR/lib/sdl_cursor.so" ./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish

# Auto-hide can resume now
if [ "$NOHIDING" = true ]; then
  swaymsg 'seat * hide_cursor 1000'
fi