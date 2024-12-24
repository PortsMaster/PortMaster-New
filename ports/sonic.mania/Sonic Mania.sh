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
get_controls

# Source Device Info
source $controlfolder/device_info.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

# Set variables
GAMEDIR="/$directory/ports/sonicmania"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/libs":$LD_LIBRARY_PATH
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Permissions
$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 777 $GAMEDIR/sonicmania

# Modify PixWidth
MED=320  # 4:3
HIGH=424 # 16:9

# Calculate the aspect ratio as a floating-point number
ASPECT=$(awk "BEGIN {print $DISPLAY_WIDTH / $DISPLAY_HEIGHT}")

# Set WIDTH based on aspect ratio comparisons
WIDTH=$(awk "BEGIN {print ($ASPECT > 1.3 ? $HIGH : $MED)}")

if grep -q "^pixWidth=[0-9]\+" "$GAMEDIR/Settings.ini"; then
  sed -i "s/^pixWidth=[0-9]\+/pixWidth=$WIDTH/" "$GAMEDIR/Settings.ini"
  sed -i "s/^fsWidth=[0-9]\+/fsWidth=$DISPLAY_WIDTH/" "$GAMEDIR/Settings.ini"
  sed -i "s/^fsHeight=[0-9]\+/fsHeight=$DISPLAY_HEIGHT/" "$GAMEDIR/Settings.ini"
else
  echo "Possible invalid or missing settings.ini!" > $CUR_TTY
fi

# Run the game
echo "Loading, please wait!" > $CUR_TTY
$GPTOKEYB "sonicmania" &
./sonicmania

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty1
