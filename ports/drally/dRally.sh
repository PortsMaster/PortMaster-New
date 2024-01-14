#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
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
GAMEDIR="$PORTDIR/drally"
cd $GAMEDIR

$ESUDO chmod 666 $CUR_TTY
$ESUDO touch log.txt
$ESUDO chmod 666 log.txt
export TERM=linux
printf "\033c" > $CUR_TTY

## RUN SCRIPT HERE
if [ -f "DeathRallyWin_10.exe" ]; then
  echo "Extracting DeathRallyWin_10.exe" > $CUR_TTY
  $EUSDO ./7z e -y DeathRallyWin_10.exe
  $EUSDO rm -f DeathRallyWin_10.exe
fi

if [ ! -f "TR0.BPA" ]; then
  echo "Game files missing, check README for installation instructions." > $CUR_TTY
  sleep 5
  exit
fi

echo "Starting game." > $CUR_TTY

$GPTOKEYB "drally_linux" -c drally.gptk textinput &
$TASKSET ./drally_linux 2>&1 | $ESUDO tee -a ./log.txt

$ESUDO kill -9 $(pidof gptokeyb)
unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
$ESUDO systemctl restart oga_events &

# Disable console
printf "\033c" > $CUR_TTY
