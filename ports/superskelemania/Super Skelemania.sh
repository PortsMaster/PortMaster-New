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

GAMEDIR="/$directory/ports/superskelemania"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_linux"

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

# Check if there are .ogg files in ./gamedata
if [ -n "$(ls ./gamedata/*.ogg 2>/dev/null)" ]; then
  # Move all .ogg files from ./gamedata to ./assets
  mv ./gamedata/*.ogg ./assets/
  echo "Moved .ogg files from ./gamedata to ./assets/"
  # Zip the contents of ./sm.apk including the new .ogg files
  zip -r -0 ./game.apk ./game.apk ./assets/
  rm -f ./assets/*.ogg
  echo "Zipped contents to ./game.apk"
  # Delete uneeded files
  rm -f ./gamedata/*.exe
  rm -f ./gamedata/*.dll
  rm -f ./gamedata/*.ini
fi

# Check for file existence before trying to manipulate them:
[ -f "./gamedata/data.win" ] && mv gamedata/data.win gamedata/game.droid
[ -f "./gamedata/game.win" ] && mv gamedata/game.win gamedata/game.droid
[ -f "./gamedata/game.unx" ] && mv gamedata/game.unx gamedata/game.droid

$GPTOKEYB "gmloader" -c ./superskelemania.gptk &

$ESUDO chmod +x "$GAMEDIR/gmloader"
pm_platform_helper "$GAMEDIR/gmloader"
./gmloader game.apk

pm_finish
