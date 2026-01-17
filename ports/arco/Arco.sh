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
GAMEDIR="/$directory/ports/arco"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x -R $GAMEDIR/*

# Exports
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/tools/lib:$LD_LIBRARY_PATH"
export controlfolder
export DISPLAY_WIDTH
export DISPLAY_HEIGHT

# Check if we need to patch the game
if [ ! -f arco.love ]; then
    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        export PATCHER_FILE="$GAMEDIR/tools/patchscript"
        export PATCHER_GAME="$(basename "${0%.*}")"
        export PATCHER_TIME="about a minute"
        export controlfolder
        export ESUDO
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb)
    else
        echo "This port requires the latest version of PortMaster."
    fi
fi

# Set zram swap file for Arkos
ZRAM_ENABLED=false
if [[ $CFW_NAME == *"ArkOS"* ]]; then
  TARGET_SIZE=$((200 * 1024 * 1024))  
  
  get_current_size() {
    if [ -b /dev/zram0 ]; then
      # Added --bytes to ensure we are comparing exact numbers
      $ESUDO zramctl --output SIZE --noheadings --bytes /dev/zram0 2>/dev/null | tr -d ' '
    else
      echo 0
    fi
  }
  
  current_size=$(get_current_size)
  
  # If it's already 200MB or more, we're good
  if [ "${current_size:-0}" -ge "$TARGET_SIZE" ]; then
    echo "zram0 swap already sufficient ($current_size bytes)."
    ZRAM_ENABLED=true
  else
    # If it exists but is the wrong size, reset it
    if [ "${current_size:-0}" -gt 0 ]; then
      echo "zram0 size mismatch, resetting to 200MB..."
      $ESUDO swapoff /dev/zram0 2>/dev/null || true
      $ESUDO zramctl --reset /dev/zram0 2>/dev/null || true
    fi
    
    echo "Creating 200MB zram0 swap..."
    $ESUDO zramctl --find --size "$TARGET_SIZE"
    $ESUDO mkswap /dev/zram0 >/dev/null
    $ESUDO swapon /dev/zram0
    ZRAM_ENABLED=true
  fi
fi

# Config
mkdir -p "$GAMEDIR/save"
bind_directories "$XDG_DATA_HOME/love/arco/save" "$GAMEDIR/save"
source $controlfolder/runtimes/"love_11.5"/love.txt

# Run the love runtime
$GPTOKEYB "$LOVE_GPTK" &
pm_platform_helper "$LOVE_BINARY"
$LOVE_RUN "$GAMEDIR/arco.love"

# Cleanup
if [ "$ZRAM_ENABLED" = true ]; then
	$ESUDO swapoff /dev/zram0 2>/dev/null || true
fi
pm_finish
