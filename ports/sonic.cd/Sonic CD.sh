#!/bin/bash
# PORTMASTER: sonic.cd.zip, Sonic CD.sh

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
get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

# Set variables
GAMEDIR="/$directory/ports/soniccd"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x -R $GAMEDIR/*

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/libs":$LD_LIBRARY_PATH
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Setup gl4es environment
if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

# Permissions
$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 777 $GAMEDIR/soniccd

# Modify ScreenWidth
LOW=214 # 3:2
MED=320 # 4:3
HIGH=426 # 16:9

# Calculate the aspect ratio with floating-point precision
ASPECT=$(awk -v w="$DISPLAY_WIDTH" -v h="$DISPLAY_HEIGHT" 'BEGIN { printf "%.2f", w / h }')

# Set WIDTH based on the calculated aspect ratio
if (( $(echo "$ASPECT == 1.50" | bc -l) )); then
    WIDTH=$LOW  # 3:2
elif (( $(echo "$ASPECT == 1.33" | bc -l) )); then
    WIDTH=$MED  # 4:3
elif (( $(echo "$ASPECT == 1.78" | bc -l) )); then
    WIDTH=$HIGH  # 16:9
else
    echo "Unknown aspect ratio: $ASPECT"
    WIDTH=$MED  # Default value if aspect ratio is unknown
fi

if grep -q "^ScreenWidth=[0-9]\+" "$GAMEDIR/settings.ini"; then
    sed -i "s/^ScreenWidth=[0-9]\+/ScreenWidth=$WIDTH/" "$GAMEDIR/settings.ini"
else
    echo "Possible invalid or missing settings.ini!" > $CUR_TTY
fi

# Run the game
$GPTOKEYB "soniccd" -c "sonic.gptk" &
pm_platform_helper "soniccd"
./soniccd

# Cleanup
pm_finish