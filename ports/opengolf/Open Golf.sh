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

GAMEBINARY=golf
GAMEDIR=/$directory/ports/opengolf
: > "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR
chmod +x "$GAMEBINARY.${DEVICE_ARCH}"

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"

# Launcher (Love2D): Play and the controls image. There are no game settings, so no config file (-)
rm -f "$GAMEDIR/launch.cfg"
source $controlfolder/runtimes/"love_11.5"/love.txt
$LOVE_RUN "$GAMEDIR/launcher" - "$GAMEDIR/launch.cfg"

# Continue only if the user chose Play (launcher writes LAUNCHER_PLAY=1 to launch.cfg)
if ! grep -qx "LAUNCHER_PLAY=1" "$GAMEDIR/launch.cfg" 2>/dev/null; then
  pm_finish
  exit 0
fi

# Game data ships as assets.tar.gz; extract on first run and after an update.
# extract/ (shared Love2D include) shows the message while it extracts and closes when
# done; it also shows the error if assets.tar.gz is missing or extraction fails.
if [[ -f assets.tar.gz || ! -d data ]]; then
  [[ -d data ]] && $ESUDO rm -rf data
  $LOVE_RUN "$GAMEDIR/extract" assets.tar.gz || exit 1
  $ESUDO rm -f assets.tar.gz
fi

# The game reads the gamepad itself; gptokeyb only provides the exit hotkey
$GPTOKEYB "$GAMEBINARY.${DEVICE_ARCH}" &
pm_platform_helper "$GAMEDIR/$GAMEBINARY.${DEVICE_ARCH}"
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./$GAMEBINARY.${DEVICE_ARCH}
pm_finish
