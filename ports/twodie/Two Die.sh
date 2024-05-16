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

GAMEDIR="/$directory/ports/twodie"

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

GAME_FILE="Two Die.exe"
LAUNCH_FILE="twodie"

if [ -f "$GAME_FILE" ]; then
  ./bin/7za d "$GAME_FILE" "luasteam.dll"
  ./bin/7za d "$GAME_FILE" "steam_api64.dll"
  LUASTEAM_FILE="luasteam.lua"
  cp "patch/$LUASTEAM_FILE" "$LUASTEAM_FILE"
  ./bin/7za u -aoa -y "$GAME_FILE" "$LUASTEAM_FILE"
  rm "$LUASTEAM_FILE"
  
  mainlua_file="main.lua"
  ./bin/7za x "$GAME_FILE" "$mainlua_file"
  sed -i "s/love\.graphics\.draw(gTextures\['cursor'\]/--love\.graphics\.draw(gTextures\['cursor'\]/" "$mainlua_file"
  sed -i "s/updateMouseActivity()/--updateMouseActivity()/" "$mainlua_file"  
  ./bin/7za u -aoa -y "$GAME_FILE" "$mainlua_file"
  rm "$mainlua_file"
  
  mv "$GAME_FILE" "$LAUNCH_FILE"
fi

export XDG_DATA_HOME="$GAMEDIR/conf" # allowing saving to the same path as the game
export XDG_CONFIG_HOME="$GAMEDIR/conf"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CONFIG_HOME"

$GPTOKEYB "love" -c twodie.gptk &
./bin/love "$LAUNCH_FILE"

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
