#!/bin/bash
# PORTMASTER: SNfetchPLAYER.sh

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

source "$controlfolder/control.txt"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/snfetchplayer"

cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

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
    $ESUDO umount "${python_dir}" 2>/dev/null || true
fi

$ESUDO mount "$controlfolder/libs/${runtime}.squashfs" "${python_dir}"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export SDL_VIDEO_WAYLAND_WMCLASS="python3"
export SDL_VIDEO_X11_WMCLASS="python3"
export SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0

if [ -f "/etc/ssl/certs/ca-certificates.crt" ]; then
  export SSL_CERT_FILE="/etc/ssl/certs/ca-certificates.crt"
elif [ -f "/etc/pki/tls/certs/ca-bundle.crt" ]; then
  export SSL_CERT_FILE="/etc/pki/tls/certs/ca-bundle.crt"
elif [ -f "/etc/ssl/cert.pem" ]; then
  export SSL_CERT_FILE="/etc/ssl/cert.pem"
fi

$GPTOKEYB "python3" -c "$GAMEDIR/snfetchplayer.gptk" &

pm_platform_helper "${python_dir}/bin/python3"

source "${python_dir}/bin/activate"
export PYTHONHOME="${python_dir}"
export PYTHONPATH="${GAMEDIR}/pylib"
export PYTHONPYCACHEPREFIX="${GAMEDIR}/${runtime}.cache"

"${python_dir}/bin/python3" "${GAMEDIR}/player.py" "$@"

if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${python_dir}" 2>/dev/null || true
fi

pm_finish
