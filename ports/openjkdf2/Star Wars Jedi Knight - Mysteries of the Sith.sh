#!/bin/bash

export OPENJKDF2_MOTS=1

export OPENJKDF2_HANDHELD=1
export OPENJKDF2_CHEATS_MENU=1
export OPENJKDF2_HUD_SCALE=2.0

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

GAMEDIR="/$directory/ports/openjkdf2"
CONFDIR="$GAMEDIR/conf"
mkdir -p "$CONFDIR/openjkdf2" "$CONFDIR/openjkmots"

cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export XDG_DATA_HOME="$CONFDIR"
bind_directories "$HOME/.local/share/openjkdf2" "$CONFDIR/openjkdf2"
bind_directories "$HOME/.local/share/openjkmots" "$CONFDIR/openjkmots"

export OPENJKDF2_ROOT="$GAMEDIR/jk1"
export OPENJKMOTS_ROOT="$GAMEDIR/mots"

[ -z "${OPENJKDF2_SWAY_FULLSCREEN+x}" ] && [ "${CFW_NAME^^}" = "ROCKNIX" ] && export OPENJKDF2_SWAY_FULLSCREEN=0
[ "${CFW_NAME^^}" = "ROCKNIX" ] && export SDL_HINT_APP_NAME="${SDL_HINT_APP_NAME:-OpenJKDF2}"
[ "${CFW_NAME^^}" = "ROCKNIX" ] && export SDL_OPENGL_ES_DRIVER="${SDL_OPENGL_ES_DRIVER:-1}"

. "$GAMEDIR/helpers/swap.inc"
. "$GAMEDIR/helpers/gamepad.inc"

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

openjkdf2_ignore_handheld_if_external
openjkdf2_ensure_swap

$ESUDO chmod +x "$GAMEDIR/openjkdf2.${DEVICE_ARCH}"
$GPTOKEYB "openjkdf2.${DEVICE_ARCH}" -c "./openjkdf2.gptk" &
pm_platform_helper "$GAMEDIR/openjkdf2.${DEVICE_ARCH}"

./openjkdf2.${DEVICE_ARCH} -motsCompat

pm_finish
