#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-${HOME}/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
	controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
	controlfolder="/opt/tools/PortMaster"
elif [ -d "${XDG_DATA_HOME}/PortMaster/" ]; then
	controlfolder="${XDG_DATA_HOME}/PortMaster"
else
	controlfolder="/roms/ports/PortMaster"
fi

source "${controlfolder}/control.txt"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/${directory}/ports/romm"
LOG_DIR="${GAMEDIR}/logs"
runtime="python_3.11"
python_dir="tmp/python"

mkdir -p "${LOG_DIR}"

cd "${GAMEDIR}" || exit 1

export LOG_FILE="${LOG_DIR}/$(date +'%Y-%m-%d').log"
export PYSDL2_DLL_PATH="/usr/lib"
export LD_LIBRARY_PATH="${GAMEDIR}/libs:${LD_LIBRARY_PATH}"
export SDL_GAMECONTROLLERCONFIG="${sdl_controllerconfig}"

firstboot() {
    if unzip "$GAMEDIR/romm-firstboot.zip"; then
        rm -f "$GAMEDIR/romm-firstboot.zip"
    else
        pm_message "Failed to unzip romm-firstboot.zip"
        exit 1
    fi
}

compare() {
    v1="$1"
    v2="$2"
    [ "$(printf '%s\n' "$v2" "$v1" | sort -V | head -n1)" = "$v2" ]
}

use_runtime() {
    if [ ! -f "$controlfolder/libs/${runtime}.squashfs" ]; then
        if [ ! -f "$controlfolder/harbourmaster" ]; then
            pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/"
            sleep 5
            exit 1
        fi
        $ESUDO "$controlfolder/harbourmaster" --quiet --no-check runtime_check "${runtime}.squashfs"
    fi

    $ESUDO mkdir -p "${python_dir}"
    $ESUDO umount "$controlfolder/libs/${runtime}.squashfs" 2>/dev/null || true
    $ESUDO mount "$controlfolder/libs/${runtime}.squashfs" "${python_dir}"

    export PYTHONHOME="${python_dir}"
    export PATH="${python_dir}/bin:$PATH"
    export LD_LIBRARY_PATH="${python_dir}/libs:${LD_LIBRARY_PATH}"
    python="${python_dir}/bin/python3"
}

# If first boot, unzip the package
if [ -f "romm-firstboot.zip" ]; then
    firstboot
fi

# Default to system python3
python=$(which python3)

if [ -x "$python" ]; then
    PYTHON_VERSION=$($python -c 'import sys; print("{}.{}".format(sys.version_info[0], sys.version_info[1]))')
else
    PYTHON_VERSION="0.0"
fi

REQUIRED_VERSION="3.10"

if ! compare "$PYTHON_VERSION" "$REQUIRED_VERSION"; then
    use_runtime
fi

# Run the app
pm_platform_helper "$python" >/dev/null
$python main.py > "${LOG_FILE}" 2>&1

# Cleanup
pm_finish
