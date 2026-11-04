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

GAMEDIR="/$directory/ports/choochootracker"
CONFDIR="$GAMEDIR/conf"
mkdir -p "$CONFDIR"
mkdir -p "$CONFDIR/.choochootracker"
cd "$GAMEDIR" || exit 1

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export XDG_DATA_HOME="$CONFDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export HOTKEY=guide
# Keep ArkOS's default ALSA route so its volume controls affect playback.
# Some installations cannot open that route, so the audio backend may retry
# with the internal card. Respect a device already chosen by the user/platform.
if [ "$CFW_NAME" = "ArkOS" ] && [ -z "$AUDIODEV" ]; then
  export CCT_AUDIODEV_FALLBACK="plughw:0,0"
fi

bind_directories ~/.choochootracker "$CONFDIR/.choochootracker"

$ESUDO chmod +x "./choochootracker.${DEVICE_ARCH}" || exit 1

# ROCKNIX can emit Select and Guide together; the old mapper loses Shift-up.
if [ "$CFW_NAME" = "ROCKNIX" ]; then
  $GPTOKEYB2 "choochootracker.${DEVICE_ARCH}" -c "./choochootracker.gptk" &
else
  $GPTOKEYB "choochootracker.${DEVICE_ARCH}" -c "./choochootracker.gptk" &
fi
pm_platform_helper "$GAMEDIR/choochootracker.${DEVICE_ARCH}"
"./choochootracker.${DEVICE_ARCH}"

pm_finish
