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
source $controlfolder/device_info.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/descent2"
DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
GAME="d2x-rebirth"
ASPECT_X=${ASPECT_X:-4}
ASPECT_Y=${ASPECT_Y:-3}

cd $GAMEDIR

$ESUDO rm -rf ~/.$GAME
ln -sfv $GAMEDIR/config ~/.$GAME

export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export SDL_FORCE_SOUNDFONTS=1
export SDL_SOUNDFONTS="$GAMEDIR/soundfont.sf2"

# Add some cheats
if [ ! -f "./cheats.txt" ]; then
	echo "Error: Cheats file not found. No cheats will be used." > /dev/tty0
else
	CHEATS=$(sed -n -E '/^[^#]*=[[:space:]]*1([^0-9#]|$)/s/(=[[:space:]]*1[^0-9#]*)//p' ./cheats.txt | tr -d '\n')
fi

export TEXTINPUTPRESET=$CHEATS

# Edit .cfg file with updated resolution and aspect ratio
sed -i "s/^ResolutionX=640/ResolutionX=$DISPLAY_WIDTH/g" $GAMEDIR/config/descent.cfg
sed -i "s/^ResolutionY=480/ResolutionY=$DISPLAY_HEIGHT/g" $GAMEDIR/config/descent.cfg
sed -i "s/^AspectX=.*/AspectX=$ASPECT_Y/g" $GAMEDIR/config/descent.cfg
sed -i "s/^AspectY=.*/AspectY=$ASPECT_X/g" $GAMEDIR/config/descent.cfg

# Setup controls
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

# List of compatibility firmwares
CFW_NAMES="ArkOS:ArkOS wuMMLe:ArkOS AeUX:knulli:TrimUI"

# Check if the current CFW name is in the list
contains() {
    local value="$CFW_NAME"
    local item
    local tmp=$IFS
    IFS=":" # Use : as the delimiter
    echo "Checking if CFW_NAME '$value' is in the list..."
    for item in $CFW_NAMES; do
        echo "Comparing '$item' with '$value'..."
        if [ "$item" = "$value" ]; then
            echo "Match found: '$item'"
            IFS=$tmp
            return 0
        fi
    done
    echo "No match found for '$value'."
    IFS=$tmp
    return 1
}

# If it's in the list use the compatibility binary
if contains; then
	$GPTOKEYB "$GAME.compat" -c "config/joy.gptk" & 
	SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
	./$GAME.compat -hogdir data
else
	$GPTOKEYB "$GAME.$DEVICE_ARCH" -c "config/joy.gptk" & 
	SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
	./$GAME.$DEVICE_ARCH -hogdir data
fi

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events & 
printf "\033c" >> /dev/tty1