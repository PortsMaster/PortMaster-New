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

GAMEDIR="/$directory/ports/ohmygodlookatthisknight"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_linux"

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

# Extract and patch file
if [ -f "./gamedata/OH_MY_GOD__LOOK_AT_THIS_KNIGHT.exe" ]; then
  # Patch data.win
  $controlfolder/xdelta3 -d -s "./gamedata/data.win" "./gamedata/patch.xdelta3" "./gamedata/game.droid"
  [ $? -eq 0 ] && rm "./gamedata/data.win" || echo "Patching of data.win has failed"
  # Move all .ogg files from ./gamedata to ./assets
  mv ./gamedata/*.ogg ./assets/
  echo "Moved .ogg files from ./gamedata to ./assets/"
  # Zip the contents of ./sm.apk including the new .ogg files
  zip -r -0 ./game.apk ./game.apk ./assets/
  rm -f ./assets/*.ogg
  echo "Zipped contents to ./game.apk"
  # Delete unneeded files
  rm -f gamedata/*.{dll,exe}
fi

$GPTOKEYB "gmloader" -c ./ohmygodlookatthisknight.gptk &

$ESUDO chmod +x "$GAMEDIR/gmloader"
pm_platform_helper "$GAMEDIR/gmloader"
./gmloader game.apk

pm_finish
