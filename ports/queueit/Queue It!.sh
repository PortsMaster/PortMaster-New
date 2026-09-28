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

GAMEDIR="/$directory/ports/queueit"
CONFDIR="$GAMEDIR/conf"
ZIPHASH="4dc41a7b9ebec11fc4435bbb8392f772"
PATCHFILE="${GAMEDIR}/queue-it.patch"

cd "${GAMEDIR}"

> "${GAMEDIR}/log.txt" && exec > >(tee "${GAMEDIR}/log.txt") 2>&1

mkdir -p "$GAMEDIR/conf"
bind_directories "$HOME/.config/.pyxel/queue-it" "$CONFDIR"

# INSTALLATION
if [ ! -f "${GAMEDIR}/gamedata/queue-it/main.py" ]; then
    echo "${GAMEDIR}/gamedata/main.py not found"
    echo "Will try to install the gamedata"

    # Look for a zip file in gamedir (first found)
    zipfile=$(find "${GAMEDIR}" -type f -iname "*.zip" -print -quit)

    if [[ -n "$zipfile" ]]; then
        echo "Found: $zipfile"

    else
        echo "No zip found. Copy the game zip file in the port dir (${GAMEDIR})."
        exit 1
    fi

    # Check zip hash before patching
    if echo "${ZIPHASH}  ${zipfile}" | md5sum -c - >/dev/null 2>&1; then
        echo "Zip hash matched"
    else
        echo "Zip hash mismatch. Patching might fail"
    fi

    mkdir -p "${GAMEDIR}/gamedata"
    cd "${GAMEDIR}/gamedata"

    # Extract pyxapp file from the zip archive
    unzip -j "${zipfile}" "dist/queue-it/_internal/queue-it.pyxapp"

    if [ $? -ne 0 ]; then
        echo "Error while extracting the pyxel app from the zip file"
        echo "Cannot continue"
        exit 1
    fi

    # Delete zip file
    rm -f "${zipfile}"

    # Extract game files from the pyxapp file
    unzip "queue-it.pyxapp"

    if [ $? -ne 0 ]; then
        echo "Error while extracting the pyxel app file"
        echo "Cannot continue"
        exit 1
    fi

    # Delete pyxapp
    rm "queue-it.pyxapp"
    
    cd "queue-it"
    chmod a+rx "${GAMEDIR}/tools/patch"
    export PATH="$PATH:${GAMEDIR}/tools"
    patch -p1 < "${PATCHFILE}"

    if [ $? -ne 0 ]; then
        echo "Patching failed"
        echo "The game might not run as expected"
    fi

fi

cd "${GAMEDIR}"

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
#export PYTHONPATH="${GAMEDIR}/gamedata/${DEVICE_ARCH}:${PYTHONPATH:-}"

export DEVICE_NAME
export CFW_NAME

# pyxel.reset() workaround (Pyxel 2.5.0+)
#    pyxel.reset() spawns a background process and then terminates the parent
#    process. Therefore, the spawned process is left running. As a result, it
#    is highly likely to affect applications launched by the user.
#    Setting PYXEL_WATCH_STATE_FILE=/dev/null prevents this and returns
#    exit code 82, allowing this loop to safely restart the game.
# https://github.com/kitao/pyxel/blob/v2.9.5/crates/pyxel-binding/src/system_wrapper.rs#L66-L67
export PYXEL_WATCH_STATE_FILE=/dev/null

while true; do
    #"${pyxel_dir}/bin/pyxel" play "${GAMEDIR}/gamedata/${PYXEL_PKG}"
    "${pyxel_dir}/bin/pyxel" run "${GAMEDIR}/gamedata/queue-it/main.py"
    EXIT_CODE=$?

    # 0x52 (82) is returned when pyxel.reset() is called by the game (e.g. changing resolution)
    if [ $EXIT_CODE -ne 82 ]; then
        break
    fi
    echo "pyxel.reset() detected. Restarting game cleanly..."
done

if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${pyxel_dir}"
fi

pm_finish
