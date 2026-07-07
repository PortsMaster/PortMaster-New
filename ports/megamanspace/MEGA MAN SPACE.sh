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

export controlfolder

source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/megamanspace"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO chmod +x "$GAMEDIR/gmloadernext.aarch64"

check_patch() {
	if [ ! -f "$GAMEDIR/patchlog.txt" ] && [ -f "$GAMEDIR/assets/Mega Man Space v1.2.0.0.exe" ]; then
		if [ -f "$controlfolder/utils/patcher.txt" ]; then
			set -o pipefail

			export ESUDO
			export DEVICE_RAM
			export PATCHER_FILE="$GAMEDIR/tools/patchscript"
			export PATCHER_GAME="$(basename "${0%.*}")"
			export PATCHER_TIME="5 minutes"
			source "$controlfolder/utils/patcher.txt"
			$ESUDO umount "$DOTNETDIR"
		else
			pm_message "This port requires the latest version of PortMaster."
			pm_finish
			exit 1
		fi
	fi
}

check_patch

$GPTOKEYB "gmloadernext.aarch64" -c "./mega.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

pm_finish
