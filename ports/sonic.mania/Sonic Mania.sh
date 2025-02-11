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

# Set Pix Values
HMED=240 # 4:3
HHIGH=344 # 16:9
WMED=320  # 4:3
WHIGH=424 # 16:9

# Calculate aspect ratio
ASPECT=$(awk "BEGIN {print $DISPLAY_WIDTH / $DISPLAY_HEIGHT}")

# Choose Width and Height based on aspect ratio
WIDTH=$(awk "BEGIN {print ($ASPECT > 1.5 ? $WHIGH : $WMED)}")
HEIGHT=$(awk "BEGIN {print ($ASPECT > 1.5 ? $HHIGH : $HMED)}")

# Ensure pixWidth and pixHeight keys exist or are updated
if grep -q "^pixWidth=" "$GAMEDIR/Settings.ini"; then
  sed -i "s/^pixWidth=[0-9]\+/pixWidth=$WIDTH/" "$GAMEDIR/Settings.ini"
else
  sed -i "/^\[Video\]/a pixWidth=$WIDTH" "$GAMEDIR/Settings.ini"
fi

if grep -q "^pixHeight=" "$GAMEDIR/Settings.ini"; then
  sed -i "s/^pixHeight=[0-9]\+/pixHeight=$HEIGHT/" "$GAMEDIR/Settings.ini"
else
  sed -i "/^\[Video\]/a pixHeight=$HEIGHT" "$GAMEDIR/Settings.ini"
fi

# Ensure fsWidth and fsHeight keys exist or are updated
if grep -q "^fsWidth=" "$GAMEDIR/Settings.ini"; then
  sed -i "s/^fsWidth=[0-9]\+/fsWidth=$DISPLAY_WIDTH/" "$GAMEDIR/Settings.ini"
else
  sed -i "/^\[Video\]/a fsWidth=$DISPLAY_WIDTH" "$GAMEDIR/Settings.ini"
fi

if grep -q "^fsHeight=" "$GAMEDIR/Settings.ini"; then
  sed -i "s/^fsHeight=[0-9]\+/fsHeight=$DISPLAY_HEIGHT/" "$GAMEDIR/Settings.ini"
else
  sed -i "/^\[Video\]/a fsHeight=$DISPLAY_HEIGHT" "$GAMEDIR/Settings.ini"
fi


# Run the game
pm_message "Loading, please wait!"
pm_platform_helper "$GAMEDIR/sonicmania"
$GPTOKEYB "sonicmania" &
./sonicmania

# Cleanup
pm_finish