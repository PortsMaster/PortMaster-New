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

# Source the controls and device info
source $controlfolder/control.txt

# Source custom mod files from the portmaster folder
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
# Pull the controller configs for native controls
get_controls

# Directory setup
GAMEDIR=/$directory/ports/librespot
CONFDIR="$GAMEDIR/conf/"
mkdir -p "$GAMEDIR/conf"

# Set the XDG environment variables for config & savefiles for LOVE
export XDG_DATA_HOME="$CONFDIR"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
export LOVEDIR=$GAMEDIR

# Check if the cache directory size is greater than 50 MB
CACHE_DIR="$LOVEDIR/cache"
if [ -d "$CACHE_DIR" ]; then
  CACHE_SIZE_MB=$(du -sm "$CACHE_DIR" | cut -f1)
  if [ "$CACHE_SIZE_MB" -gt 50 ]; then
    rm -rf "$CACHE_DIR"
  fi
fi

# Enable logging
#> "$GAMEDIR/log.txt" && exec > >(tee "$LOVEDIR/log.txt") 2>&1

cd $GAMEDIR

# Run LOVE and Spotify
$GPTOKEYB "love" &
pm_platform_helper "$GAMEDIR/love"
./love librespotui

# Cleanup LOVE
pm_finish
printf "\033c" > /dev/tty0

