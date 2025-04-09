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

GAMEDIR="/$directory/ports/putridshotultra"

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

GAME_FILE="PutridShotUltra.exe"
LAUNCH_FILE="PutridShotUltra"

if [ -f "$GAME_FILE" ]; then
  WINDOWLUA_FILE="Engine/WindowUtils.lua"  
  ./bin/7za x "$GAME_FILE" "$WINDOWLUA_FILE"
  sed -i "s/scaleX = math\.floor/scaleX = /" "$WINDOWLUA_FILE"
  sed -i "s/scaleY = math\.floor/scaleY = /" "$WINDOWLUA_FILE"
  ./bin/7za u -mx0 -aoa "$GAME_FILE" "$WINDOWLUA_FILE"
  rm -rf "Engine"
  
  PAUSELUA_FILE="Engine/PauseMenu.lua"  
  ./bin/7za x "$GAME_FILE" "$PAUSELUA_FILE"
  sed -i 's/love.graphics\.newFont("Fonts\/PICO-8 mono\.ttf", 4)/picoFont/' "$PAUSELUA_FILE"
  ./bin/7za u -mx0 -aoa "$GAME_FILE" "$PAUSELUA_FILE"
  rm -rf "Engine"
  
  CONFLUA_FILE="conf.lua"  
  ./bin/7za x "$GAME_FILE" "$CONFLUA_FILE"
  sed -i "s/steamApiEnabled = true/steamApiEnabled = false/" "$CONFLUA_FILE"
  sed -i "s/scaleX = math\.floor/scaleX = /" "$WINDOWLUA_FILE"
  sed -i "s/scaleY = math\.floor/scaleY = /" "$WINDOWLUA_FILE"
  ./bin/7za u -mx0 -aoa "$GAME_FILE" "$CONFLUA_FILE"
  rm "$CONFLUA_FILE"
  
  mv "$GAME_FILE" "$LAUNCH_FILE"
fi

export XDG_DATA_HOME="$GAMEDIR/conf" # allowing saving to the same path as the game
export XDG_CONFIG_HOME="$GAMEDIR/conf"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CONFIG_HOME"

echo "Loading game.." > /dev/tty0

$GPTOKEYB "love" &
./bin/love $LAUNCH_FILE

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
