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
GAMEDIR="/$directory/ports/descent"
DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
GAME="d1x-rebirth"
ASPECT_X=${ASPECT_X:-4}
ASPECT_Y=${ASPECT_Y:-3}

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
rm -rf "$GAMEDIR/config/gamelog.txt"
$ESUDO chmod +x -R $GAMEDIR/*

# Set config dir
bind_directories ~/.$GAME $GAMEDIR/config

# Add some cheats
if [ ! -f "./cheats.txt" ]; then
	pm_message "Error: Cheats file not found. No cheats will be used."
else
	CHEATS=$(sed -n -E '/^[^#]*=[[:space:]]*1([^0-9#]|$)/s/(=[[:space:]]*1[^0-9#]*)//p' ./cheats.txt | tr -d '\n')
fi

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export SDL_FORCE_SOUNDFONTS=1
export SDL_SOUNDFONTS="$GAMEDIR/soundfont.sf2"
export TEXTINPUTPRESET=$CHEATS
export TEXTINPUTINTERACTIVE="Y"
export TEXTINPUTNUMBERSONLY="Y"

# Edit .cfg file with updated resolution and aspect ratio
sed -i "s/^ResolutionX=[0-9]\{1,4\}/ResolutionX=$DISPLAY_WIDTH/g" "$GAMEDIR/config/descent.cfg"
sed -i "s/^ResolutionY=[0-9]\{1,4\}/ResolutionY=$DISPLAY_HEIGHT/g" "$GAMEDIR/config/descent.cfg"
sed -i "s/^AspectX=[0-9]\{1,2\}/AspectX=$ASPECT_Y/g" "$GAMEDIR/config/descent.cfg"
sed -i "s/^AspectY=[0-9]\{1,2\}/AspectY=$ASPECT_X/g" "$GAMEDIR/config/descent.cfg"

# Use compatibility binary if low glibc
if [ $CFW_GLIBC -lt 234 ]; then
	GAME="$GAME.compat"
else
    GAME="$GAME.$DEVICE_ARCH"
fi

# Run game
$GPTOKEYB "$GAME" -c "config/joy.gptk" &
pm_platform_helper "$GAMEDIR/$GAME"
./$GAME -hogdir data

# Cleanup
pm_finish
