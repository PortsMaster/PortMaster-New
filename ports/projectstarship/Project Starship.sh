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

GAMEDIR="/$directory/ports/projectstarship"
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64

export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TOOLDIR="$GAMEDIR/tools"
export PATH="$TOOLDIR:$PATH"

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [ "$CFW_NAME" == "knulli" ] && [ -f "./tools/7zzs" ]; then
    $ESUDO chmod +x ./tools/7zzs
fi

if [ -f "./assets/project_starship.exe" ]; then
    echo "Extracting zip..."
    ./tools/7zzs e "./assets/project_starship.exe" -o"./assets/" -y
    if [ $? -eq 0 ]; then
        echo "Extraction successful. Cleaning up..."
        rm -f "./assets/project_starship.exe"
        rm -f ./assets/.gitkeep
        rm -f ./assets/HD_VDeck.lnk
        rm -f ./assets/steam_api.dll
        rm -f ./assets/D3DX9_43.dll
        rm -f ./assets/options.ini
        rm -f ./license/LICENSE.7zzs.txt
        rm -rf ./tools
    else
        echo "Extraction failed. Skipping cleanup of zip."
    fi
fi

find ./assets -type f -name "project Starship.exe" -delete

[ -e "./assets/data.win" ] && mv ./assets/data.win ./assets/game.droid

if [ -f ./assets/game.droid ]; then
    mv ./assets/game.droid ./assets/game.droid
    sleep 1
    zip -r -0 "$GAMEDIR/prostar.port" assets
    rm -rf "$GAMEDIR/assets"
fi

$GPTOKEYB "gmloadernext.aarch64" -c "./prostar.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "gmloader.json"

pm_finish