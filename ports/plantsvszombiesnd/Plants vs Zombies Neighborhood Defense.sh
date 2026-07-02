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
GAMEDIR="/$directory/ports/plantsvszombiesnd"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# CD and set up logging
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64

# Exports
export LD_LIBRARY_PATH="/usr/lib:$LD_LIBRARY_PATH"

# Unpack textures
if [ -f $GAMEDIR/saves/textures/textures.zip ]; then
	pm_message "Unpacking game files, please wait"
	# Extracting textures.zip
	unzip -j -o "$GAMEDIR/saves/textures/textures.zip" -d "$GAMEDIR/saves/textures"
	rm -Rf $GAMEDIR/saves/textures/textures.zip
fi

echo "DISPLAY_WIDTH: $DISPLAY_WIDTH"

# Adjust dpad_mouse_step and deadzone_scale based on resolution width
if [ "$DISPLAY_WIDTH" -lt 1280 ]; then
    echo "Setting dpad_mouse_step and deadzone_scale to 5"
    sed -i -E 's/(dpad_mouse_step|deadzone_scale) = [0-9]/\1 = 5/g' plantsvszombiesnd.gptk
elif [ "$DISPLAY_WIDTH" -lt 1920 ]; then
    echo "Setting dpad_mouse_step and deadzone_scale to 6"
    sed -i -E 's/(dpad_mouse_step|deadzone_scale) = [0-9]/\1 = 6/g' plantsvszombiesnd.gptk
else
    echo "Setting dpad_mouse_step and deadzone_scale to 7"
    sed -i -E 's/(dpad_mouse_step|deadzone_scale) = [0-9]/\1 = 7/g' plantsvszombiesnd.gptk
fi

# Set zram swap file for Arkos / dArkos
ZRAM_ENABLED=false
if [[ $CFW_NAME == *"ArkOS"* ]]; then
	TARGET_SIZE=$((300 * 1024 * 1024))  # bytes
	# Helper: current zram size in bytes (0 if none)
	get_current_size() {
		if [ -b /dev/zram0 ]; then
			$ESUDO zramctl --output NAME,SIZE --noheadings /dev/zram0 2>/dev/null \
			| awk '{print $2}'
		else
			echo 0
		fi
	}
	
	current_size=$(get_current_size)
	if [ "$current_size" -ge "$TARGET_SIZE" ] 2>/dev/null; then
		echo "zram0 swap already >= 300MB ($current_size bytes), nothing to do."
	else
		# If it exists but too small, tear it down first
		if [ "$current_size" -gt 0 ] 2>/dev/null; then
			echo "zram0 swap too small ($current_size bytes), recreating..."
			$ESUDO swapoff /dev/zram0 2>/dev/null || true
			$ESUDO zramctl --reset /dev/zram0 2>/dev/null || true
		fi
		
		echo "Creating zram0 swap at 300MB..."
		$ESUDO zramctl --find --size "$TARGET_SIZE" || {
			echo "Failed to create zram device"
			exit 1
		}
		
		$ESUDO mkswap /dev/zram0 >/dev/null
		$ESUDO swapon /dev/zram0
		ZRAM_ENABLED=true
	fi
fi

# Disable cursor auto-hide if on Rocknix
if [[ ${CFW_NAME} == ROCKNIX ]]; then
  swaymsg 'seat * hide_cursor 0'
  NOHIDING=true
fi

# Assign gptokeyb and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "plantsvszombiesnd.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Kill processes
pm_finish

# Cleanup: disable zram if we enabled it
if [ "$ZRAM_ENABLED" = true ]; then
	$ESUDO swapoff /dev/zram0 2>/dev/null || true
fi

# Auto-hide can resume now
if [ "$NOHIDING" = true ]; then
  swaymsg 'seat * hide_cursor 1000'
fi