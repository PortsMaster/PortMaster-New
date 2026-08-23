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

GAMEDIR=/$directory/ports/impostorfactory
BINARY=mkxp-freebird.${DEVICE_ARCH}

CONFDIR="$GAMEDIR/conf/"
mkdir -p "$GAMEDIR/conf"
cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export XDG_DATA_HOME="$CONFDIR"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

WOG_FILE=$(ls impostor_factory*.sh 2> /dev/null | head -n 1)

if [ -f "$WOG_FILE" ]; then
    unzip -o "$WOG_FILE"
    if [ -d "data/noarch/game" ]; then
        $ESUDO mv -f data/noarch/game/* "$GAMEDIR/gamedata/" || { pm_message "Failed to move game directory."; sleep 5; exit 1; }
    else
        pm_message "Game directory not found after extraction."
        sleep 5
        exit 1
    fi
    $ESUDO rm -rf data/ meta/ scripts/
    rm -f "$WOG_FILE"
fi

[ -d gamedata/lib64 ] && $ESUDO rm -rf gamedata/lib64
[ -f "$BINARY" ] && $ESUDO mv "$BINARY" "gamedata/$BINARY"
[ -f gamedata/mkxp.conf ] && sed -i 's/frameSkip=true/frameSkip=false/' gamedata/mkxp.conf

cd gamedata

$GPTOKEYB2 "mkxp-freebird" -c "$GAMEDIR/impostorfactory.ini" &

pm_platform_helper "$GAMEDIR/gamedata/$BINARY"

./$BINARY --preloadScript="$GAMEDIR/patches/ums_name_fix.rb"

pm_finish
