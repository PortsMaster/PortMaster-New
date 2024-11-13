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
export PORT_32BIT="Y"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/lostethereal"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_linux"

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR
# Extract and add .ogg files to .apk
if [ -f "./gamedata/Lost Ethereal.exe" ]; then
    ./7zzs x "./gamedata/Lost Ethereal.exe" -o"./gamedata/"
    mv ./gamedata/*.ogg ./assets/ 2>/dev/null
    zip -r -0 ./game.apk ./assets/
    echo "Zipped contents to ./game.apk"
    # Delete unneeded files
    rm -Rf ./assets/
    rm -f gamedata/*.{dll,ini,exe}
fi

# Check for file existence before trying to manipulate them:
[ -f "./gamedata/data.win" ] && mv gamedata/data.win gamedata/game.droid
[ -f "./gamedata/game.win" ] && mv gamedata/game.win gamedata/game.droid
[ -f "./gamedata/game.unx" ] && mv gamedata/game.unx gamedata/game.droid

$GPTOKEYB "gmloader" -c "lostethereal.gptk" &
$ESUDO chmod +x "$GAMEDIR/gmloader"
pm_platform_helper "$GAMEDIR/gmloader"
./gmloader game.apk

pm_finish
