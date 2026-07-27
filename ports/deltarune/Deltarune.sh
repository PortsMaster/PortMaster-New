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
GAMEDIR="/$directory/ports/deltarune"

# CD and set log
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Permissions
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64
$ESUDO chmod +x $GAMEDIR/tools/ffmpeg

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$GAMEDIR/libs:$LD_LIBRARY_PATH"

export controlfolder
export DEVICE_ARCH

# Pretend we're on SteamDeck, some game code needs this
export SteamDeck=1

check_patch() {
    # Check for items in install folder (excluding base.port), data.win, or other subfolders
    install_items=$(find "$GAMEDIR/assets/install" -maxdepth 1 -mindepth 1 -not -name "base.port")
    has_data_win=$( [ -f "$GAMEDIR/assets/data.win" ] && echo true || echo false )
    has_other_subdir=$(find "$GAMEDIR/assets" -mindepth 1 -maxdepth 1 -type d ! -name "install" | head -n 1)

    # If patchlog.txt is missing, or we have installable items, data.win, or other subdirs
    if [ ! -f "$GAMEDIR/patchlog.txt" ] || [ -n "$install_items" ] || [ "$has_data_win" = true ] || [ -n "$has_other_subdir" ]; then
        if [ -f "$controlfolder/utils/patcher.txt" ]; then
            set -o pipefail
			
            # Setup and execute the Portmaster Patcher utility with our patch file
            export ESUDO
            export PATCHER_FILE="$GAMEDIR/tools/patchscript"
            export PATCHER_GAME="$(basename "${0%.*}")"
            export PATCHER_TIME="quite a while, so watch an episode of your favorite show."
            source "$controlfolder/utils/patcher.txt"
        else
            pm_message "This port requires the latest version of PortMaster."
            pm_finish
            exit 1
        fi
    fi
}

# Check if we need to patch the game
check_patch

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


# Assign gptokeyb and load the game
$GPTOKEYB "gmloadernext.aarch64" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64" >/dev/null
./gmloadernext.aarch64 -c gmloader.json

# Kill processes
pm_finish

# Cleanup: disable zram if we enabled it
if [ "$ZRAM_ENABLED" = true ]; then
	$ESUDO swapoff /dev/zram0 2>/dev/null || true
fi

