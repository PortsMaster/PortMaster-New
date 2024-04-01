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

get_controls

GAMEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/kenslabyrinth"

if [ $ANALOG_STICKS == '1' ]; then
    GPTOKEYB_CONFIG="$GAMEDIR/ken1joy.gptk"  
elif [ $DEVICE_NAME == 'x55' ] || [ $DEVICE_NAME == 'RG353P' ]; then
    GPTOKEYB_CONFIG="$GAMEDIR/kentriggers.gptk"  
else
    GPTOKEYB_CONFIG="$GAMEDIR/ken.gptk"
fi

$ESUDO cp -f -v $GAMEDIR/template.ini $GAMEDIR/settings.ini

$ESUDO chmod ugo+rwx -R $GAMEDIR/*
$ESUDO chmod ugo+rwx $GAMEDIR/../*.sh

if [[ $DISPLAY_WIDTH != '640' ]]; then
    sed -i 's/1 6400480 1 1 1 1/1 $DISPLAY_WIDTH0$DISPLAY_HEIGHT 1 1 1 1/' $GAMEDIR/settings.ini
fi

cd $GAMEDIR

# system
export LD_LIBRARY_PATH=$GAMEDIR/libs:/usr/lib:$LD_LIBRARY_PATH

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO rm $GAMEDIR/log.txt

$GPTOKEYB "ken" -c "$GPTOKEYB_CONFIG" &
./ken 2>&1 | tee -a ./log.txt

$ESUDO kill -9 $(pidof gptokeyb)
unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
$ESUDO systemctl restart oga_events &

# Disable console
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty0

