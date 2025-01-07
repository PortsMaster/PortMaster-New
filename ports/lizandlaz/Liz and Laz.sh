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

GAMEDIR="/$directory/ports/lizandlaz"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_linux"

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

# Patch data.win
if [ -f "./gamedata/Liz and Laz 1.exe" ]; then
  $controlfolder/xdelta3 -d -s "./gamedata/data.win" "./gamedata/patch.xdelta3" "./gamedata/game.droid"
  [ $? -eq 0 ] && rm "./gamedata/data.win" || pm_message "Patching of data.win has failed"
  # Delete unneeded files
  rm -f gamedata/*.{dll,exe,mp3}
fi

# Check if there are any .ogg or .mp3 files in the ./gamedata directory
if [ -n "$(ls ./gamedata/*.ogg 2>/dev/null)" ]; then
  mkdir -p ./assets
  mv ./gamedata/*.mp3 ./assets/ 2>/dev/null
  pm_message "Moved .mp3 files from ./gamedata to ./assets/"
  zip -r -0 ./game.apk ./assets/
  pm_message "Zipped contents to ./game.apk"
  rm -Rf ./assets/
fi

$GPTOKEYB "gmloader" -c ./lizandlaz.gptk &

$ESUDO chmod +x "$GAMEDIR/gmloader"
pm_platform_helper "$GAMEDIR/gmloader"
./gmloader game.apk

pm_finish
