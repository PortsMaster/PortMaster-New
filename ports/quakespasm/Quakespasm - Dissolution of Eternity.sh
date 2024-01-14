#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source "$controlfolder/control.txt"

get_controls

GAMEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/quakespasm"

# Load directly into an expansion, a map, or a mod
RUNMOD="-game rogue"

cd $GAMEDIR

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

# System
export LD_LIBRARY_PATH=$GAMEDIR/gl4es:$GAMEDIR/libs

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# gl4es
export LIBGL_ES=1
export LIBGL_GL=15

$ESUDO rm $GAMEDIR/log.txt

printf "\033c" > /dev/tty0
echo " " > /dev/tty0
echo "Press 'L2' to QuickSave" > /dev/tty0
echo "Press 'R2' to QuickLoad" > /dev/tty0
echo " " > /dev/tty0
sleep 2

$GPTOKEYB "quakespasm" -c "$GAMEDIR/quakespasm.gptk" &
./quakespasm -current +scr_showfps 1 +joy_enable 1 +r_oldwater 1 +r_particles 1 +r_shadows 0 +r_sky_quality 6 $RUNMOD 2>&1 | tee $GAMEDIR/log.txt

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events
unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty0
