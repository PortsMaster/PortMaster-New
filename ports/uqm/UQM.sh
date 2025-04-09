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

GAMEDIR=/$directory/ports/UQM

if [[ ! -f "/roms/ports/UQM/config/uqm.cfg" ]]; then
	if [[ $LOWRES == "Y" ]]; then
        mv -f $GAMEDIR/config/uqm.cfg.480 $GAMEDIR/config/uqm.cfg
        rm -f $GAMEDIR/config/uqm.cfg.640
	else
        mv -f $GAMEDIR/config/uqm.cfg.640 $GAMEDIR/config/uqm.cfg
        rm -f $GAMEDIR/config/uqm.cfg.480
    fi
fi

cd $GAMEDIR

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "uqm" -c "./uqm.gptk" &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./uqm --logfile $GAMEDIR/uqmlog.txt -x --contentdir=$GAMEDIR/content --configdir=$GAMEDIR/config
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1

