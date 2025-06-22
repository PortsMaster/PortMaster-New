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

GAMEDIR="/$directory/ports/megawitter"
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TOOLDIR="$GAMEDIR/tools"
export PATH="$TOOLDIR:$PATH"

if [ -f "./assets/Mega Man Witter Domination.zip" ]; then
    ./tools/7zzs x "./assets/Mega Man Witter Domination.zip" -o"./assets/"
fi

rm -f ./assets/D3DX9_43.dll
rm -f ./assets/options.ini
rm -rf ./assets/Mega Man Witter Domination.exe

[ -e "./assets/data.win" ] && mv ./assets/data.win ./assets/game.droid

if [ -f ./assets/game.droid ]; then
    mkdir -p "$GAMEDIR/assets"
    mv "$GAMEDIR/assets/game.droid" "$GAMEDIR/assets/"
    sleep 1
    cd $GAMEDIR
    zip -r -0 $GAMEDIR/megawitter.port assets
    rm -rf "$GAMEDIR/assets"
fi

$GPTOKEYB "gmloadernext.aarch64" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "gmloader.json"

pm_finish
