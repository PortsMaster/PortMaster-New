#!/bin/bash
# PORTMASTER: amos_capture.zip, capture.sh
# ROCKNIX Screen Capture - Screenshot & Video Recording

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
source $controlfolder/control.txt 2>/dev/null || directory="roms"

# Source custom mod files from the portmaster folder
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

# Directory setup - use storage path directly if directory var not set
if [ -z "$directory" ]; then
    GAMEDIR="/storage/roms/ports/amos_capture"
else
    GAMEDIR="/$directory/ports/amos_capture"
fi

CONFDIR="$GAMEDIR/conf/"
mkdir -p "$GAMEDIR/conf"
mkdir -p /storage/roms/screenshots
mkdir -p /storage/roms/recordings

cd $GAMEDIR

# Check for Python 3
if ! command -v python3 &>/dev/null; then
    echo "ERROR: Python 3 is required but not found"
    exit 1
fi

# Parse arguments
MODE=${1:-ui}  # ui, screenshot, record

case "$MODE" in
    screenshot)
        python3 capture.py screenshot
        ;;
    record)
        DURATION=${2:-10}
        FPS=${3:-10}
        python3 capture.py record -d $DURATION -f $FPS
        ;;
    ui|*)
        # Run LÖVE UI
        export XDG_DATA_HOME="$CONFDIR"
        export LOVEDIR=$GAMEDIR

        # Pull the controller configs for native controls (this resets LD_LIBRARY_PATH)
        get_controls 2>/dev/null || true

        # Set LD_LIBRARY_PATH AFTER get_controls since it overwrites it
        export LD_LIBRARY_PATH="$GAMEDIR/libs:/usr/lib/compat:$LD_LIBRARY_PATH"

        $GPTOKEYB "love" &
        pm_platform_helper "$GAMEDIR/love" 2>/dev/null || true
        ./love captureui

        pm_finish 2>/dev/null || true
        printf "\033c" > /dev/tty0
        ;;
esac
