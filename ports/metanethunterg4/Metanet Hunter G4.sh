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

GAMEDIR="/$directory/ports/metanethunterg4"

export XDG_DATA_HOME="$GAMEDIR/conf" # allowing saving to the same path as the game
export XDG_CONFIG_HOME="$GAMEDIR/conf"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CONFIG_HOME"

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

game_name="Metanet Hunter G4"
full_game_name="$game_name (v1.2)"
demo_game_name="$game_name DEMO"
launch_file="metanethunterg4"

if [ -f "$full_game_name.exe" ]; then
  game_file="$full_game_name.exe"
elif [ -f "$full_game_name.love" ]; then
  game_file="$full_game_name.love"
elif [ -f "$demo_game_name.exe" ]; then
  game_file="$demo_game_name.exe"
fi

if [ -f "$game_file" ]; then
  rm "$launch_file"
  
  patch_file="shaders/mono.psh"
  ./bin/7za x "$game_file" "$patch_file"
  sed -i 's/== 0)/== 0\.0)/' "$patch_file"
  ./bin/7za u -mx0 -aoa -y "$game_file" "$patch_file"
  rm -rf "shaders"

  patch_file="core/init.lua"
  ./bin/7za x "$game_file" "$patch_file"
  sed -i 's/self\.height, true/self\.height, false/' "$patch_file"
  sed -i 's/fullscreen = false/fullscreen = true/' "$patch_file"
  ./bin/7za u -mx0 -aoa -y "$game_file" "$patch_file"
  rm -rf "core"

  mv "$game_file" "$launch_file"
fi

$GPTOKEYB "love" &
./bin/love "$launch_file"

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0