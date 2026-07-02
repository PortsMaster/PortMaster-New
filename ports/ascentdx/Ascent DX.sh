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
GAMEDIR="/$directory/ports/ascentdx"
GAME_FILE="ascent_dx.exe"
LAUNCH_FILE="ascent_dx.love"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x -R $GAMEDIR/*

# Exports
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/tools/lib:$LD_LIBRARY_PATH"

# Check if 7zzs present
if [ ! -f "$controlfolder/7zzs.${DEVICE_ARCH}" ]; then
    echo "this port requires the latest portmaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
fi

# Patch and rename game on first-time set up
if [ -f "$GAME_FILE" ]; then
  echo "Patching for OpenGL ES compatibility, scale, and VSync..."
  
  # Calculate optimal scale based on display resolution
  # Game canvas is 64x64, so we calculate how many times it fits
  SCALE_X=$((DISPLAY_WIDTH / 64))
  SCALE_Y=$((DISPLAY_HEIGHT / 64))
  # Use the smaller of the two to ensure it fits on screen
  OPTIMAL_SCALE=$((SCALE_X < SCALE_Y ? SCALE_X : SCALE_Y))
  # Clamp between 2 and 20
  OPTIMAL_SCALE=$((OPTIMAL_SCALE < 2 ? 2 : OPTIMAL_SCALE))
  OPTIMAL_SCALE=$((OPTIMAL_SCALE > 20 ? 20 : OPTIMAL_SCALE))
  # Round down to nearest even number (multiple of 2)
  OPTIMAL_SCALE=$((OPTIMAL_SCALE - (OPTIMAL_SCALE % 2)))
  # Make sure it's at least 2
  OPTIMAL_SCALE=$((OPTIMAL_SCALE < 2 ? 2 : OPTIMAL_SCALE))
  
  echo "Display resolution: ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}"
  echo "Calculated optimal scale: ${OPTIMAL_SCALE}x (${OPTIMAL_SCALE} * 64 = $((OPTIMAL_SCALE * 64))px)"
  
  # Extract the archive
  mkdir -p "$GAMEDIR/temp_patch"
  cd "$GAMEDIR/temp_patch"
  "$controlfolder/7zzs.${DEVICE_ARCH}" x "$GAMEDIR/$GAME_FILE" -y > /dev/null 2>&1
  
  
  # Patch 1: Update scale and add low performance mode setting in project_main.lua
  if [ -f "src/project_main.lua" ]; then
    echo "Setting scale to ${OPTIMAL_SCALE}x, target framerate to 60 FPS, and adding performance mode..."
    # Replace line 30: skrovet.set_window("Ascent DX", 64, 64, 10)
    sed -i "s/skrovet\.set_window(\"Ascent DX\", 64, 64, [0-9]\+)/skrovet.set_window(\"Ascent DX\", 64, 64, ${OPTIMAL_SCALE})/" src/project_main.lua
    # Replace line 41: skrovet.system.set_setting("scale", 10)
    sed -i "s/skrovet\.system\.set_setting(\"scale\", [0-9]\+)/skrovet.system.set_setting(\"scale\", ${OPTIMAL_SCALE})/" src/project_main.lua
    # Replace line 56: Set FPS to 60
    sed -i "s/skrovet\.set_window(\"Ascent DX\", 64, 64, skrovet\.system\.get_setting(\"scale\"), [0-9]\+)/skrovet.set_window(\"Ascent DX\", 64, 64, skrovet.system.get_setting(\"scale\"), 60)/" src/project_main.lua
    
    # Add low_performance_mode setting initialization (only if not already present)
    if ! grep -q "low_performance_mode" src/project_main.lua; then
      sed -i '/skrovet\.system\.set_setting("fullscreen", false)/a\        skrovet.system.set_setting("low_performance_mode", false)' src/project_main.lua
    fi
    
    # Add check for low_performance_mode in else block (only if not already present)
    if ! grep -q "if skrovet.system.get_setting.*low_performance_mode" src/project_main.lua; then
      sed -i '/skrovet\.system\.set_setting("starts",/i\    -- Ensure low_performance_mode setting exists\n    if skrovet.system.get_setting("low_performance_mode") == nil then\n        skrovet.system.set_setting("low_performance_mode", false)\n    end\n' src/project_main.lua
    fi
    
    echo "Scale, framerate, and performance mode patched successfully!"
  else
    echo "WARNING: src/project_main.lua not found!"
  fi
  
  # Repack the archive
  echo "Repacking as $LAUNCH_FILE..."
  "$controlfolder/7zzs.${DEVICE_ARCH}" a -tzip "$GAMEDIR/$LAUNCH_FILE" ./* > /dev/null 2>&1
  
  # Clean up
  cd "$GAMEDIR"
  rm -rf temp_patch
  rm -f "$GAME_FILE"
  
  echo "Patching complete!"
fi

# Config
mkdir -p "$GAMEDIR/save"
bind_directories "$XDG_DATA_HOME/love/ascent_dx/" "$GAMEDIR/save"
source $controlfolder/runtimes/"love_11.5"/love.txt

# Run the love runtime
$GPTOKEYB "$LOVE_GPTK" &
pm_platform_helper "$LOVE_BINARY"
$LOVE_RUN "$GAMEDIR/ascent_dx.love"

pm_finish