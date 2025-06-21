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

#
# This was tested with the Steam MacOS version 1.0.0.66 of the game and is found to be working with ArkOS, AmberElec, muOS and Rocknix
# For muOS, enable swap 512 and zram 256 for patching to happen. Disable swap and zram thereafter
# game.ios md5 = 556de0eeade64d9a2336335f9f3bf3a4
# Download using the Steam Console: download_depot 1123450 1123452 2137359438458453377
#

export controlfolder
source $controlfolder/control.txt
source $controlfolder/tasksetter
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

export ESUDO=$ESUDO
export GAMEDIR="/$directory/ports/chicoryact"
cd "$GAMEDIR"

# Log execution
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Setup other misc environment variables
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Ensure executable permissions
$ESUDO chmod +x "$GAMEDIR/gmloadernext.aarch64"
$ESUDO chmod +x "$GAMEDIR/tools/gmKtool.py"
$ESUDO chmod +x "$GAMEDIR/tools/oggdec"
$ESUDO chmod +x "$GAMEDIR/tools/oggenc"
$ESUDO chmod +x "$GAMEDIR/tools/patchscript"
$ESUDO chmod +x "$GAMEDIR/tools/splash"

# Function to create temporary swap file
create_swap() {
    local swap_size="${1:-1G}"  # Default 1GB swap
    local swap_file="$GAMEDIR/temp_swap"
    
    echo "Creating temporary swap file of size $swap_size..."
    
    # Check available disk space
    local available_kb=$(df "$GAMEDIR" | awk 'NR==2 {print $4}')
    local swap_size_kb
    local count_mb
    
    case $swap_size in
        *G|*g)
            swap_size_kb=$((${swap_size%[Gg]} * 1024 * 1024))
            count_mb=$((${swap_size%[Gg]} * 1024))
            ;;
        *M|*m)
            swap_size_kb=$((${swap_size%[Mm]} * 1024))
            count_mb=${swap_size%[Mm]}
            ;;
        *)
            echo "Unsupported swap size format"
            return 1
            ;;
    esac
    
    if [ "$available_kb" -lt "$swap_size_kb" ]; then
        echo "Warning: Not enough disk space for $swap_size swap. Available: ${available_kb}KB"
        return 1
    fi
    
    # Create swap file
    if ! dd if=/dev/zero of="$swap_file" bs=1M count=$count_mb status=none; then
        echo "Failed to create swap file"
        return 1
    fi
    
    # Set permissions properly (with sudo if needed)
    if [ -n "$ESUDO" ]; then
        $ESUDO chmod 600 "$swap_file"
    else
        chmod 600 "$swap_file"
    fi
    
    if [ -n "$ESUDO" ]; then
        if ! $ESUDO mkswap "$swap_file" >/dev/null 2>&1; then
            echo "Error: Failed to format swap file with sudo"
            rm -f "$swap_file"
            return 1
        fi
    else
        if ! mkswap "$swap_file" >/dev/null 2>&1; then
            echo "Error: Failed to format swap file"
            rm -f "$swap_file"
            return 1
        fi
    fi
    
    # Enable swap with sudo if available
    if [ -n "$ESUDO" ]; then
        if ! $ESUDO swapon "$swap_file" >/dev/null 2>&1; then
            echo "Failed to enable swap file with sudo"
            rm -f "$swap_file"
            return 1
        fi
    else
        if ! swapon "$swap_file" >/dev/null 2>&1; then
            echo "Failed to enable swap file (no sudo available)"
            rm -f "$swap_file"
            return 1
        fi
    fi
    
    echo "Temporary swap file created and enabled: $swap_file"
    return 0
}


# Function to remove temporary swap file
remove_swap() {
    local swap_file="$GAMEDIR/temp_swap"
    
    if [ -f "$swap_file" ]; then
        echo "Removing temporary swap file..."
        if command -v "$ESUDO" >/dev/null 2>&1; then
            $ESUDO swapoff "$swap_file" 2>/dev/null || true
        else
            swapoff "$swap_file" 2>/dev/null || true
        fi
        rm -f "$swap_file"
        echo "Temporary swap file removed"
    fi
}

# Check if we need to patch
if [ ! -f install_completed ]; then
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
        # Set up device swap file if RAM 1GB and not muOS OR knulli
	    if [ "$DEVICE_RAM" -lt 2 ] && [ "$CFW_NAME" != "muOS" ] && [ "$CFW_NAME" != "knulli" ]; then
	    create_swap 512M
	    fi
	    export PATCHER_FILE="$GAMEDIR/tools/patchscript"
	    export PATCHER_GAME="Chicory: A Colorful Tale"
	    export PATCHER_TIME="30 to 60 minutes"
	    source "$controlfolder/utils/patcher.txt"
	    $ESUDO umount "$DOTNETDIR"
	else
	    pm_message "This port requires the latest version of PortMaster."
	    pm_finish
	    exit 1
	fi
fi

# Display loading splash
if [ -f install_completed  ]; then
    remove_swap
    # Generate a random number (1 or 2)
    RND=$(od -An -N1 -tu1 /dev/urandom)
    RND=$(( (RND % 2) + 1 ))

    # Select splash image based on random number
    case $RND in
        1) SPLASH="$GAMEDIR/tools/splash-1.png" ;;
        2) SPLASH="$GAMEDIR/tools/splash-2.png" ;;
    esac

    [ "$CFW_NAME" = "muOS" ] && $ESUDO "$GAMEDIR/tools/splash" "$SPLASH" 1
    $ESUDO "$GAMEDIR/tools/splash" "$SPLASH" 10000 &
fi

$GPTOKEYB "gmloadernext.aarch64" -c "chicoryact.gptk" & 
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64" > /dev/null
$TASKSET ./gmloadernext.aarch64 -c gmloader.json

pm_finish