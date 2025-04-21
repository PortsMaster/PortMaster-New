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

CUR_TTY=/dev/tty0

PORTDIR="/$directory/ports"
GAMEDIR="$PORTDIR/gemrb"
cd $GAMEDIR

$ESUDO chmod 666 $CUR_TTY
$ESUDO touch log.txt
$ESUDO chmod 666 log.txt
$ESUDO chmod 666 /dev/uinput
export TERM=linux
printf "\033c" > $CUR_TTY

GAME="iwd"

# Extract the game engine if necessary
if [ -f "$GAMEDIR/engine.zip" ]; then
  if [ -d "$GAMEDIR/engine" ]; then
    $ESUDO echo "Removing old engine."
    $ESUDO rm -fRv "$GAMEDIR/engine"
  fi
  $ESUDO unzip "$GAMEDIR/engine.zip"
  $ESUDO mv -fv "$GAMEDIR/engine/gemrb" "$GAMEDIR/gemrb"
  $ESUDO rm -f "$GAMEDIR/engine.zip"
fi

# Install appropriate GemRB.cfg
if [ ! -f "${GAMEDIR}/games/${GAME}/GemRB.cfg" ]; then
  if [ -f "${GAMEDIR}/configs/GemRB.cfg.${GAME}" ]; then
    $ESUDO cp -v "${GAMEDIR}/configs/GemRB.cfg.${GAME}" "${GAMEDIR}/games/${GAME}/GemRB.cfg"
  else
    $ESUDO cp -v "${GAMEDIR}/configs/GemRB.cfg.default" "${GAMEDIR}/games/${GAME}/GemRB.cfg"
  fi
fi

# Controller config
if [ -f "${GAMEDIR}/gemrb-${GAME}.gptk" ]; then
  GPTOKEYB_CFG="${GAMEDIR}/gemrb-${GAME}.gptk"
else
  GPTOKEYB_CFG="${GAMEDIR}/gemrb.gptk"
fi

export TEXTINPUTPRESET="Name"
export TEXTINPUTINTERACTIVE="Y"
export TEXTINPUTNOAUTOCAPITALS="Y"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export PYTHONHOME="$GAMEDIR"
export LD_LIBRARY_PATH="$GAMEDIR/lib:$LD_LIBRARY_PATH"

$GPTOKEYB "gemrb" -c "${GPTOKEYB_CFG}" textinput &
$TASKSET ./gemrb -c "${GAMEDIR}/games/${GAME}/GemRB.cfg" "${GAMEDIR}/games/${GAME}/" 2>&1 | $ESUDO tee -a ./log.txt

pm_finish
