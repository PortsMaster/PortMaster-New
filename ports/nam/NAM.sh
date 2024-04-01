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

GAMEDIR="/$directory/ports/rednukem-NAM"

# if [[ ! -e $GAMEDIR/conf/rednukem/rednukem.cfg ]]; then
  if   [[ $LOWRES == 'Y' && $ANALOGSTICKS == '1' ]]; then
    mv -f $GAMEDIR/conf/rednukem/rednukem.cfg.480 $GAMEDIR/conf/rednukem/rednukem.cfg
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.640
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.480.2analogs
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.640.2analogs
  elif [[ $LOWRES == 'Y' && $ANALOGSTICKS == '2' ]]; then
    mv -f $GAMEDIR/conf/rednukem/rednukem.cfg.480.2analogs $GAMEDIR/conf/rednukem/rednukem.cfg
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.640
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.480
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.640.2analogs
  elif [[ $LOWRES == 'N' && $ANALOGSTICKS == '1' ]]; then
    mv -f $GAMEDIR/conf/rednukem/rednukem.cfg.640 $GAMEDIR/conf/rednukem/rednukem.cfg
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.480
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.480.2analogs
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.640.2analogs
  elif [[ $LOWRES == 'N' && $ANALOGSTICKS == '2' ]]; then
    mv -f $GAMEDIR/conf/rednukem/rednukem.cfg.640.2analogs $GAMEDIR/conf/rednukem/rednukem.cfg
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.480
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.480.2analogs
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.640
  fi
# fi

$ESUDO rm -rf ~/.config/rednukem
$ESUDO ln -s $GAMEDIR/conf/rednukem ~/.config/
cd $GAMEDIR
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "rednukem" &
LD_LIBRARY_PATH="$GAMEDIR/lib:$LD_LIBRARY_PATH" SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./rednukem -game_dir $GAMEDIR/gamedata -gamegrp NAM.GRP 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1
