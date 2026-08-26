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

GAMEDIR="/$directory/ports/angrydd"

cd "${GAMEDIR}"

> "${GAMEDIR}/log.txt" && exec > >(tee "${GAMEDIR}/log.txt") 2>&1

ARCHIVE_FILE="gamedata.tar.gz"
if [[ -f "$ARCHIVE_FILE" ]]; then
    pm_message "Extracting game data, this can take a few minutes..."
    if gunzip -c "$ARCHIVE_FILE" | tar xf -; then
        pm_message "Extraction successful."
        $ESUDO rm -f "$ARCHIVE_FILE"
    else
        pm_message "Error: Extraction failed."
        sleep 5
        exit 1
    fi
elif [ ! -f 'angrydd.py' ]; then
    pm_message "Error: No game data present and Archive file $ARCHIVE_FILE not found."
    sleep 5
    exit 1
fi

runtime="python_3.11"
export python_dir="$HOME/python_3.11"
mkdir -p "${python_dir}"

if [ ! -f "$controlfolder/libs/${runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi

  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${runtime}.squashfs"
fi

if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${python_dir}"
fi

$ESUDO mount "$controlfolder/libs/${runtime}.squashfs" "${python_dir}"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$GPTOKEYB2 "python3" -c "$GAMEDIR/angrydd.ini" &

pm_platform_helper "${python_dir}/bin/python3"

source "${python_dir}/bin/activate"
export PYTHONHOME="${python_dir}"
export PYTHONPATH="${GAMEDIR}/pylib"
export PYTHONPYCACHEPREFIX="${GAMEDIR}/${runtime}.cache"

"${python_dir}/bin/python3" "${GAMEDIR}/angrydd.py"

if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${python_dir}"
fi

pm_finish
