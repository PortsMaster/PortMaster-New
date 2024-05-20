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

GAMEDIR="/$directory/ports/rednukem-redneck2"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# if [[ ! -e $GAMEDIR/conf/rednukem/rednukem.cfg ]]; then
  if   [[ $LOWRES == 'Y' && $ANALOG_STICKS == '1' ]]; then
    mv -f $GAMEDIR/conf/rednukem/rednukem.cfg.480 $GAMEDIR/conf/rednukem/rednukem.cfg
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.640
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.480.2analogs
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.640.2analogs
  elif [[ $LOWRES == 'Y' && $ANALOG_STICKS == '2' ]]; then
    mv -f $GAMEDIR/conf/rednukem/rednukem.cfg.480.2analogs $GAMEDIR/conf/rednukem/rednukem.cfg
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.640
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.480
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.640.2analogs
  elif [[ $LOWRES == 'N' && $ANALOG_STICKS == '1' ]]; then
    mv -f $GAMEDIR/conf/rednukem/rednukem.cfg.640 $GAMEDIR/conf/rednukem/rednukem.cfg
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.480
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.480.2analogs
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.640.2analogs
  elif [[ $LOWRES == 'N' && $ANALOG_STICKS == '2' ]]; then
    mv -f $GAMEDIR/conf/rednukem/rednukem.cfg.640.2analogs $GAMEDIR/conf/rednukem/rednukem.cfg
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.480
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.480.2analogs
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.640
  fi
# fi

$ESUDO rm -rf ~/.config/rednukem
$ESUDO ln -s $GAMEDIR/conf/rednukem ~/.config/

export LD_LIBRARY_PATH="$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

cd $GAMEDIR

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "rednukem" &
./rednukem -game_dir $GAMEDIR/gamedata -gamegrp REDNECK.GRP

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1

