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

GAMEDIR="/$directory/ports/Exhumed"

if   [[ $ANALOGSTICKS == '1' ]]; then
  if [ ! -f "$GAMEDIR/conf/pcexhumed/pcexhumed.cfg" ]; then
     mv -f $GAMEDIR/conf/pcexhumed/pcexhumed.cfg.1analog $GAMEDIR/conf/pcexhumed/pcexhumed.cfg
     rm -f $GAMEDIR/conf/pcexhumed/pcexhumed.cfg.2analog
  fi
  if [ ! -f "$GAMEDIR/pcexhumed.gptk" ]; then
     mv -f $GAMEDIR/pcexhumed.gptk.1analog $GAMEDIR/pcexhumed.gptk
     rm -f $GAMEDIR/pcexhumed.gptk.2analog
  fi
elif [[ $ANALOGSTICKS == '2' ]]; then
  if [ ! -f "$GAMEDIR/conf/pcexhumed/pcexhumed.cfg" ]; then
     mv -f $GAMEDIR/conf/pcexhumed/pcexhumed.cfg.2analog $GAMEDIR/conf/pcexhumed/pcexhumed.cfg
     rm -f $GAMEDIR/conf/pcexhumed/pcexhumed.cfg.1analog
  fi
  if [ ! -f "$GAMEDIR/pcexhumed.gptk" ]; then
     mv -f $GAMEDIR/pcexhumed.gptk.2analog $GAMEDIR/pcexhumed.gptk
     rm -f $GAMEDIR/pcexhumed.gptk.1analog
  fi
fi

$ESUDO rm -rf ~/.config/pcexhumed
$ESUDO ln -s $GAMEDIR/conf/pcexhumed ~/.config/
cd $GAMEDIR

export TEXTINPUTINTERACTIVE="Y"

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "pcexhumed" -c "./pcexhumed.gptk" &
LD_LIBRARY_PATH="$GAMEDIR/lib:$LD_LIBRARY_PATH" SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./pcexhumed 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
pgrep -f pcexhumed | $ESUDO xargs kill -9
unset TEXTINPUTINTERACTIVE
printf "\033c" >> /dev/tty1
