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

source $controlfolder/device_info.txt
source $controlfolder/control.txt

get_controls

GAMEDIR="/$directory/ports/quake2"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$GPTOKEYB "quake2" -c "$GAMEDIR/quake2.gptk" &
./quake2 +set vid_renderer gles3 +set r_customwidth $DISPLAY_WIDTH +set r_customheight $DISPLAY_HEIGHT +set r_hudscale 3 +set r_menuscale 3 -datadir $GAMEDIR +set vid_fullscreen 2 -portable

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
printf "\033c" > /dev/tty1
