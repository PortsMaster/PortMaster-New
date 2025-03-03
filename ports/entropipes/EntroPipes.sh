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

GAMEDIR=/$directory/ports/entropipes
CONFDIR="$GAMEDIR/conf"
PYXEL_PKG="entropipes.pyxapp"

cd "${GAMEDIR}"

> "${GAMEDIR}/log.txt" && exec > >(tee "${GAMEDIR}/log.txt") 2>&1

mkdir -p "$GAMEDIR/conf"
bind_directories "$HOME/.config/.pyxel/entropipes" "$CONFDIR"
# note: replace gamename with the appropriate value for the game

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

# play the pyxel package stored in gamedata
"${pyxel_dir}/bin/pyxel" play "${GAMEDIR}/${PYXEL_PKG}"

# Alternatively, run a python script file
# "${pyxel_dir}/bin/pyxel" run gamedata/main.py

if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${pyxel_dir}"
fi

pm_finish
