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

GAMEDIR="/$directory/ports/dungeonantiqua2"
CONFDIR="$GAMEDIR/conf"
PYXEL_PKG="dungeon-antiqua2.pyxapp"

cd "${GAMEDIR}"

> "${GAMEDIR}/log.txt" && exec > >(tee "${GAMEDIR}/log.txt") 2>&1

mkdir -p "$GAMEDIR/conf"
bind_directories "$HOME/.config/.pyxel/dungeon-antiqua2" "$CONFDIR"

# Load Pyxel runtime
runtime="pyxel_2.9.5_python_3.11"

# TMPDIR configuration (Pyxel 2.5.4+)
#    Pyxel 2.5.4+ changed the temporary directory naming from PID (numeric) to PID_UUID.
#    Older Pyxel runtimes crash when they find the new format in the shared
#    /tmp/.pyxel/play/ directory. This setting uses a temporary directory common to
#    Pyxel v2.9.5 and newer runtimes to avoid conflicts.
SYS_TEMP="${TMPDIR:-/tmp}"
export TMPDIR="${SYS_TEMP}/.pyx-v295up"
mkdir -p "$TMPDIR"

export pyxel_dir="$HOME/$runtime"
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

# Library path configuration
#    ${pyxel_dir}/libs.${DEVICE_ARCH} : libffi.so.7 bundled in the runtime
#        (required since Pyxel 2.8.2; ctypes unconditionally imports libffi)
export LD_LIBRARY_PATH="${pyxel_dir}/libs.${DEVICE_ARCH}:${LD_LIBRARY_PATH}"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$GPTOKEYB "pyxel" &

pm_platform_helper "${pyxel_dir}/bin/pyxel"

# Enable Pyxel virtual env
source "${pyxel_dir}/bin/activate"
export PYTHONHOME="${pyxel_dir}"
export PYTHONPYCACHEPREFIX="${GAMEDIR}/${runtime}.cache"
export PYTHONPATH="${GAMEDIR}/gamedata/${DEVICE_ARCH}:${PYTHONPATH:-}"

export DEVICE_NAME
export CFW_NAME
"${pyxel_dir}/bin/pyxel" play "${GAMEDIR}/gamedata/${PYXEL_PKG}"

if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${pyxel_dir}"
fi

pm_finish

