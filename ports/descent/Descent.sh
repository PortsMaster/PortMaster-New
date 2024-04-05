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

source $controlfolder/device_info.txt

GAME="d1x-rebirth"
GAMEDIR="/$directory/ports/descent"

cd $GAMEDIR

$ESUDO rm -rf ~/.$GAME
ln -sfv $GAMEDIR/conf/.$GAME ~/

export LIBGL_FB=4
export LD_LIBRARY_PATH=$GAMEDIR/libs:/usr/lib
export SDL_FORCE_SOUNDFONTS=1
export SDL_SOUNDFONTS="$GAMEDIR/libs/soundfont.sf2"

# Add some cheats
if [ ! -f "./cheats.txt" ]; then
	echo "Error: Cheats file not found. No cheats will be used." > /dev/tty0
else
	CHEATS=$(sed -n -E '/^[^#]*=[[:space:]]*1([^0-9#]|$)/s/(=[[:space:]]*1[^0-9#]*)//p' ./cheats.txt | tr -d '\n')
fi

export TEXTINPUTPRESET=$CHEATS

# Edit .cfg file to correct resolution
sed -i "s/^ResolutionX=640/ResolutionX=$DISPLAY_WIDTH/g" $GAMEDIR/conf/.$GAME/descent.cfg
sed -i "s/^ResolutionY=480/ResolutionY=$DISPLAY_HEIGHT/g" $GAMEDIR/conf/.$GAME/descent.cfg

# Setup controls
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "$GAME" -c "conf/joy.gptk" & 
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Run the game
./$GAME -hogdir data
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events & 
printf "\033c" >> /dev/tty1

