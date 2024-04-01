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
source $controlfolder/device_info.txt

get_controls

## TODO: Change to PortMaster/tty when Johnnyonflame merges the changes in,
CUR_TTY=/dev/tty0

PORTDIR="/$directory/ports"
GAMEDIR="$PORTDIR/augustus"
cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO chmod 666 $CUR_TTY
export TERM=linux
printf "\033c" > $CUR_TTY

printf "\033c" > $CUR_TTY
## RUN SCRIPT HERE

if [ ! -f "$GAMEDIR/data/c3.eng" ] && [ ! -f "$GAMEDIR/data/c3_mm.eng" ]; then
  echo "Missing game files, see README for more info." > $CUR_TTY
  sleep 5
  printf "\033c" > $CUR_TTY
  $ESUDO systemctl restart oga_events &
  exit 1
fi

# Extract the game if it exists
if [ -f "$GAMEDIR/assets.zip" ]; then
  if [ -d "$GAMEDIR/data/assets" ]; then
    echo "Removing old assets. One moment." > $CUR_TTY
    $ESUDO rm -fRv "$GAMEDIR/data/assets"
  fi

  echo "Extracting assets." > $CUR_TTY
  # Extract the assets from the build zip.
  cd data/
  $ESUDO unzip "$GAMEDIR/assets.zip"
  cd ..
  $ESUDO rm -f "$GAMEDIR/assets.zip"
fi

if [ "$ANALOG_STICKS" = "0" ]; then
  sed -i 's/up = up/up = mouse_movement_up/' augustus.gptk
  sed -i 's/down = down/down = mouse_movement_down/' augustus.gptk
  sed -i 's/left = left/left = mouse_movement_left/' augustus.gptk
  sed -i 's/right = right/right = mouse_movement_right/' augustus.gptk
fi


echo "Starting game." > $CUR_TTY

$GPTOKEYB "augustus.${DEVICE_ARCH}" -c augustus.gptk &
./augustus.${DEVICE_ARCH} data/

$ESUDO kill -9 $(pidof gptokeyb)
unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
$ESUDO systemctl restart oga_events &

# Disable console
printf "\033c" > $CUR_TTY

