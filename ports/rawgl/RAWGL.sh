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

# the included copy of oga_controls seems to breaks exiting on non oga devices...
rm -f "/$directory/ports/rawgl/oga_controls"

get_controls

GAMEDIR="/$directory/ports/rawgl"
cd $GAMEDIR

$ESUDO chmod 666 /dev/tty1
# use gptokeyb instead
$GPTOKEYB "rawgl" & 

if [[ $LOWRES == "Y" ]]; then
  rawgl_screen="--window=480x320"
elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
  rawgl_screen="--window=854x480"
else
  rawgl_screen="--window=640x480"
fi
# add support for 3DO iso file
GAMEDATA="$(ls $GAMEDIR/gamedata/*.iso | head -1)"
if [[ "$GAMEDATA" == "" ]]; then
  GAMEDATA="$GAMEDIR/gamedata"
fi
LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH" SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./rawgl $rawgl_screen --render=software --datapath="$GAMEDATA" --language=us 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1


