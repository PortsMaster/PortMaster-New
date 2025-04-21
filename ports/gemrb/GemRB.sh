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
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/gemrb"
CONFDIR="$GAMEDIR/conf"

cd "${GAMEDIR}"

# Make all .sh files executable
chmod +x "${GAMEDIR}"/*.sh

> "${GAMEDIR}/log.txt" && exec > >(tee "${GAMEDIR}/log.txt") 2>&1

if [ -z ${GAME+x} ]; then
  # Load Pyxel runtime
  runtime="pyxel_2.2.8_python_3.11"
  export pyxel_dir="$HOME/pyxel"
  mkdir -p "${pyxel_dir}"

  if [ ! -f "$controlfolder/libs/${runtime}.squashfs" ]; then
    # Check for runtime if not downloaded via PM
    if [ ! -f "$controlfolder/harbourmaster" ]; then
      pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
      sleep 5
      exit 1
    fi

    $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${runtime}.squashfs"
  fi

  if [[ "$PM_CAN_MOUNT" != "N" ]]; then
      $ESUDO umount "${pyxel_dir}"
  fi

  $ESUDO mount "$controlfolder/libs/${runtime}.squashfs" "${pyxel_dir}"

  export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

  $GPTOKEYB "pyxel" &

  pm_platform_helper "${pyxel_dir}/bin/pyxel"

  # Enable Pyxel virtual env
  source "${pyxel_dir}/bin/activate"
  export PYTHONHOME="${pyxel_dir}"
  export PYTHONPYCACHEPREFIX="${GAMEDIR}/${runtime}.cache"

  "${pyxel_dir}/bin/pyxel" run "${GAMEDIR}/launcher.py"

  GAME=$(cat "$GAMEDIR/game_select.txt")

  if [[ "$PM_CAN_MOUNT" != "N" ]]; then
      $ESUDO umount "${pyxel_dir}"
  fi

  if [[ "$GAME" == "quit" ]]; then
    pm_finish
    exit
  fi

  # Kill gptokeyb
  pm_gptokeyb_finish
fi


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
pm_platform_helper "${GAMEDIR}/gemrb"
$TASKSET ./gemrb -c "${GAMEDIR}/games/${GAME}/GemRB.cfg" "${GAMEDIR}/games/${GAME}/" 2>&1 | $ESUDO tee -a ./log.txt

pm_finish
