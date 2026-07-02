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

source "$controlfolder/control.txt"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/theforceengine"
CONFDIR="$GAMEDIR/conf"
mkdir -p "$CONFDIR"

cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export TFE_DATA_HOME="$CONFDIR"
export TFE_HANDHELD=1

[ -n "${ANALOG_STICKS+x}" ] && [ "$ANALOG_STICKS" -lt 2 ] 2>/dev/null && export TFE_HANDHELD_NO_STICKS=1

if [[ ! -f "$GAMEDIR/settings.ini" && -f "$GAMEDIR/settings.ini.example" ]]; then
  cp -a "$GAMEDIR/settings.ini.example" "$GAMEDIR/settings.ini"
fi

# --- CFW tweaks (ROCKNIX / Wayland) ---
[ -z "${TFE_SWAY_FULLSCREEN+x}" ] && [ "${CFW_NAME^^}" = "ROCKNIX" ] && export TFE_SWAY_FULLSCREEN=0
[ "${CFW_NAME^^}" = "ROCKNIX" ] && export SDL_HINT_APP_NAME="${SDL_HINT_APP_NAME:-TheForceEngine}"
[ "${CFW_NAME^^}" = "ROCKNIX" ] && export SDL_OPENGL_ES_DRIVER="${SDL_OPENGL_ES_DRIVER:-1}"

# Sound fix for ArkOS / dArkOS
if [[ "${CFW_NAME^^}" == *"ARKOS"* ]]; then
    if [ ! -f ~/.asoundrc ] && [ -f ~/.asoundrcbak ]; then
        $ESUDO cp ~/.asoundrcbak ~/.asoundrc
        $ESUDO chmod ugo+rw ~/.asoundrc
        sleep 0.5
    fi
fi

# --- Gamepad (external pad ignores built-in handheld controller) ---
. "$GAMEDIR/helpers/gamepad.inc"

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

theforceengine_ignore_handheld_if_external

$ESUDO chmod +x "$GAMEDIR/theforceengine.${DEVICE_ARCH}"

# Native SDL gamepad; gptokeyb only for exit (Select+Start)
$GPTOKEYB "theforceengine.${DEVICE_ARCH}" -c "./theforceengine.gptk" &
pm_platform_helper "$GAMEDIR/theforceengine.${DEVICE_ARCH}"
./theforceengine.${DEVICE_ARCH}

pm_finish
