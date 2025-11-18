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

# pm
source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# variables
GAMEDIR=/$directory/ports/penguneverleft
CONFDIR="$GAMEDIR/conf/"
cd $GAMEDIR

# enable logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# set xdg environment variables for config & savefiles
export XDG_DATA_HOME="$CONFDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# source love2d runtime
source $controlfolder/runtimes/"love_11.5"/love.txt

# rename game file
mv -- ./gamedata/*.love ./gamedata/PenguNeverLeft.exe
mv -- ./gamedata/*.exe ./gamedata/PenguNeverLeft.exe

# prepare files
if [ -f ./gamedata/PenguNeverLeft.exe ]; then
  pm_message "Prepare game files ..."
  mv ./gamedata/*.exe ./gamedata/PenguNeverLeft.exe
  rm -rf ./tmp_extract
  mkdir -p ./tmp_extract
  unzip -q ./gamedata/PenguNeverLeft.exe -d ./tmp_extract
  cp ./main.lua ./tmp_extract/
  rm -f ./tmp_extract/*.exe ./tmp_extract/*.dll
  (cd ./tmp_extract && zip -0 -r ../PenguNeverLeft.love .)
  rm -rf ./tmp_extract ./gamedata/* ./gamedata/.git*
  touch "./gamedata/place Pengu Never Left.exe here"
  pm_message "Launching game ..."
fi

# run the love runtime
$GPTOKEYB2 "$LOVE_GPTK" -c "./penguneverleft.ini" &
pm_platform_helper "$LOVE_BINARY"
$LOVE_RUN "$GAMEDIR/PenguNeverLeft.love"

# cleanup
pm_finish
