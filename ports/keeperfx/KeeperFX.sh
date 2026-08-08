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
[ -f "$controlfolder/device_info.txt" ] && source "$controlfolder/device_info.txt"
[ -f "$controlfolder/mod_${CFW_NAME}.txt" ] && source "$controlfolder/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/keeperfx"
cd "$GAMEDIR" || exit 1

: >"$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [ ! -f data/bluepal.dat ] || [ ! -f sound/bullfrog.sbk ] || [ ! -f fxdata/gtext_eng.dat ]; then
	pm_message "Missing KeeperFX/Dungeon Keeper data. Copy a complete legal KeeperFX installation into ports/keeperfx; see the port README."
	exit 1
fi

width=${DISPLAY_WIDTH:-640}
height=${DISPLAY_HEIGHT:-480}
sed -i.bak \
	-e "s/^FRONTEND_RES=.*/FRONTEND_RES=640x480w32 ${width}x${height}w32 ${width}x${height}w32/" \
	-e "s/^INGAME_RES=.*/INGAME_RES=${width}x${height}w32/" \
	keeperfx.cfg
rm -f keeperfx.cfg.bak

$ESUDO chmod +x keeperfx.aarch64
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH:-aarch64}:$LD_LIBRARY_PATH"

pm_platform_helper "$GAMEDIR/keeperfx.aarch64"
./keeperfx.aarch64
pm_finish
