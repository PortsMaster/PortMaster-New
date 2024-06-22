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
source $controlfolder/device_info.txt
get_controls

GAMEDIR="/$directory/ports/arkovstower"

export XDG_DATA_HOME="$GAMEDIR/conf" # allowing saving to the same path as the game
export XDG_CONFIG_HOME="$GAMEDIR/conf"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CONFIG_HOME"

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

GAME_FILE="arkovsTower.exe"
LAUNCH_FILE="arkovsTower"

if [ -f "$GAME_FILE" ]; then
  rm $LAUNCH_FILE
  
  # allow to run without steam
  LUASTEAM_FILE="luasteam.lua"
  cp "patch/$LUASTEAM_FILE" "$LUASTEAM_FILE"
  ./bin/7za u -aoa -y "$GAME_FILE" "$LUASTEAM_FILE"
  rm "$LUASTEAM_FILE"
  ./bin/7za d "$GAME_FILE" "luasteam.dll"
  
  # allow non-integer scaling for resolutions bigger than 640x480
  SETUP_FOLDER="setup"
  SCREEN_FILE="screen.lua"
  ./bin/7za x "$GAME_FILE" "$SETUP_FOLDER/$SCREEN_FILE"
  sed -i "s/if Screen.scale < 3/--if Screen.scale < 3/" "$SETUP_FOLDER/$SCREEN_FILE"
  ./bin/7za u -aoa -y "$GAME_FILE" "$SETUP_FOLDER/$SCREEN_FILE"
  rm -r $SETUP_FOLDER

  mv "$GAME_FILE" "$LAUNCH_FILE"
fi

$GPTOKEYB "love" &
./bin/love $LAUNCH_FILE

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0