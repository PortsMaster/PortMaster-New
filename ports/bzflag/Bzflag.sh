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

GAMEDIR=/$directory/ports/bzflag
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

## Game does not adhere to XDG Standard, so manually link
## Make sure to create the /conf/.bzf folders 
$ESUDO rm -rf ~/.bzf
ln -sfv $GAMEDIR/conf/.bzf ~/


export TEXTINPUTINTERACTIVE="Y"
export LD_LIBRARY_PATH="$PWD/libs::$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

cd $GAMEDIR

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "bzflag" -c "./bzflag.gptk" &

./bzflag

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
