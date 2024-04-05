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
if [ -z ${TASKSET+x} ]; then
  source $controlfolder/tasksetter
fi

get_controls

## TODO: Change to PortMaster/tty when Johnnyonflame merges the changes in,
CUR_TTY=/dev/tty0

PORTDIR="/$directory/ports"
GAMEDIR="$PORTDIR/enigma"
cd $GAMEDIR

$ESUDO chmod 666 $CUR_TTY
$ESUDO touch log.txt
$ESUDO chmod 666 log.txt
export TERM=linux
printf "\033c" >$CUR_TTY

printf "\033c" >$CUR_TTY
## RUN SCRIPT HERE

# Check if data is still archived.
if test -f "data.tar.bz2"; then
  echo "Extracting data files..." >$CUR_TTY
  tar -xf data.tar.bz2
  if [ -d "data" ]; then
    echo "Data files extracted. Cleaning up.." >$CUR_TTY
    rm data.tar.bz2
  fi
fi

# Hide makfonts.sh if it's in the data folder.
if test -f "data/fonts/mkfonts.sh"; then
  mv data/fonts/mkfonts.sh data/fonts/mkfonts.sh.bak
fi

echo "Starting game." >$CUR_TTY

export PORTMASTER_HOME="$GAMEDIR"

$GPTOKEYB "enigma" -c enigma.gptk &
LD_LIBRARY_PATH="$PWD/libs" $TASKSET ./enigma -d data 2>&1 | $ESUDO tee -a ./log.txt

$ESUDO kill -9 $(pidof gptokeyb)
unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
$ESUDO systemctl restart oga_events &

# Disable console
printf "\033c" >$CUR_TTY

