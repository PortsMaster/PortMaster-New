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
GAMEDIR="/$directory/ports/picayunedreams"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# CD and set up logging
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/lib:$LD_LIBRARY_PATH"
$ESUDO chmod +x "$GAMEDIR/gmloadernext.aarch64"
$ESUDO chmod +x "$GAMEDIR/tools/gmtoolkit.aarch64"

# Check if we need to patch the game
if [ ! -f patchlog.txt ] || [ -f "$GAMEDIR/assets/data.win" ]; then
    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        export PATCHER_FILE="$GAMEDIR/tools/patchscript"
        export PATCHER_GAME="$(basename "${0%.*}")"
        export PATCHER_TIME="20-30 minutes"
        export controlfolder
        export ESUDO
        export DISPLAY_WIDTH
        export DEVICE_RAM
        export DEVICE_ARCH
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb)
    else
        pm_message "This port requires the latest version of PortMaster."
    fi
fi
# Set zram swap file for Arkos/dArkos
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



# Assign gptokeyb and load the game
$GPTOKEYB "gmloadernext.aarch64" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64" >/dev/null
./gmloadernext.aarch64 -c "$GMLOADER_JSON"


# Kill processes
pm_finish

# Cleanup: disable zram if we enabled it
if [ "$ZRAM_ENABLED" = true ]; then
	$ESUDO swapoff /dev/zram0 2>/dev/null || true
fi