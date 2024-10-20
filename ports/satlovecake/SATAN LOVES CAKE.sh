#!/bin/bash

# Set XDG_DATA_HOME if not already set
XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

# Check for PortMaster installation in various directories
if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

# PortMaster info
source $controlfolder/control.txt
source $controlfolder/device_info.txt
GAMEDIR=/$directory/ports/satlovecake
get_controls

# Enable logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Set necessary exports
export LD_LIBRARY_PATH="/usr/lib:/usr/lib32:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/"
export GMLOADER_PLATFORM="os_windows"
export PORT_32BIT="Y"

# Change to the game directory
cd "$GAMEDIR"

# Rename data.win to game.droid if it exists in the main folder
if [ -e "$GAMEDIR/data.win" ]; then
    mv "$GAMEDIR/data.win" "$GAMEDIR/game.droid" || exit 1
    echo "Renamed data.win to game.droid."
else
    echo "No data.win file found in the main folder."
fi

# Ensure necessary permissions
$ESUDO chmod 666 /dev/uinput
$ESUDO chmod +x "$GAMEDIR/gmloadernext"

# Start game with game.droid file in $GAMEDIR
$GPTOKEYB "gmloadernext" &
./gmloadernext "$GAMEDIR/game.apk"

# Kill gptokeyb process
$ESUDO kill -9 $(pidof gptokeyb)

# Clear the console
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty0
