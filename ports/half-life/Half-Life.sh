#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/tasksetter

get_controls
CUR_TTY=/dev/tty0

PORTDIR="/$directory/ports/"
GAMEDIR="${PORTDIR}/Half-Life"
cd $GAMEDIR

# Grab text output...
$ESUDO chmod 666 $CUR_TTY
$ESUDO touch log.txt
$ESUDO chmod 666 log.txt
export TERM=linux
printf "\033c" > $CUR_TTY

## Load directly into a mod
RUNMOD=

# Install half life binaries / config files
if [[ -f "${GAMEDIR}/binaries/valve_first_run" ]]; then
  if [[ ! -f "${GAMEDIR}/valve/halflife.wad" ]]; then
    echo "Missing game files, see README for more info." > $CUR_TTY
    sleep 5
    printf "\033c" > $CUR_TTY
    $ESUDO systemctl restart oga_events &
    exit 1
  fi

  echo "Copying valve binaries/config files." > $CUR_TTY

  $ESUDO cp -rfv "${GAMEDIR}/binaries/valve" "${GAMEDIR}/" | $ESUDO tee -a ./log.txt

  # Mark step as done
  $ESUDO rm -fv "${GAMEDIR}/binaries/valve_first_run" | $ESUDO tee -a ./log.txt
fi

# Do bshift install if the files exist
if [[ -f "${GAMEDIR}/bshift/halflife.wad" ]] && [[ -f "${GAMEDIR}/binaries/bshift_first_run" ]]; then

  echo "Copying bshift binaries/config files." > $CUR_TTY

  $ESUDO cp -rfv "${GAMEDIR}/binaries/bshift" "${GAMEDIR}/" | $ESUDO tee -a ./log.txt

  # Make mod run script
  $ESUDO cp -v "${PORTDIR}/Half-Life.sh" "${PORTDIR}/Half-Life Blue Shift.sh" | $ESUDO tee -a ./log.txt
  $ESUDO sed -i 's/RUNMOD=/RUNMOD="-game bshift"/' "${PORTDIR}/Half-Life Blue Shift.sh"

  # Mark step as done
  $ESUDO rm -fv "${GAMEDIR}/binaries/bshift_first_run" | $ESUDO tee -a ./log.txt
fi

# Do opforce install if the files exist
if [[ -f "${GAMEDIR}/gearbox/OPFOR.WAD" ]] && [[ -f "${GAMEDIR}/binaries/gearbox_first_run" ]]; then

  echo "Copying gearbox binaries/config files." > $CUR_TTY

  $ESUDO cp -rfv "${GAMEDIR}/binaries/gearbox" "${GAMEDIR}/" | $ESUDO tee -a ./log.txt

  # Make mod run script
  $ESUDO cp -v "${PORTDIR}/Half-Life.sh" "${PORTDIR}/Half-Life Opposing Forces.sh"  | $ESUDO tee -a ./log.txt
  $ESUDO sed -i 's/RUNMOD=/RUNMOD="-game gearbox"/' "${PORTDIR}/Half-Life Opposing Forces.sh"

  # Mark step as done
  $ESUDO rm -fv "${GAMEDIR}/binaries/gearbox_first_run"  | $ESUDO tee -a ./log.txt
fi

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/lib32:$GAMEDIR/valve/dlls:$GAMEDIR/valve/cl_dlls"

$GPTOKEYB "xash3d" &
$TASKSET ./xash3d -ref gles2 -fullscreen -console $RUNMOD 2>&1 | tee -a ./log.txt

$ESUDO kill -9 $(pidof gptokeyb)
unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
$ESUDO systemctl restart oga_events &

# Disable console
printf "\033c" >> $CUR_TTY
