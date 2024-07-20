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

GAMEDIR=/$directory/ports/escape/
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
CONFDIR="$GAMEDIR/conf/"

# Ensure the conf directory exists
mkdir -p "$GAMEDIR/conf"

# Set the XDG environment variables for config & savefiles
export XDG_CONFIG_HOME="$CONFDIR"
export XDG_DATA_HOME="$CONFDIR"

cd $GAMEDIR

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "escape.exe" -c "./escape.gptk" &

export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" 

./escape.exe

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0

