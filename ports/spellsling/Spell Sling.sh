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

GAMEDIR="/$directory/ports/spellsling"

export XDG_DATA_HOME="$GAMEDIR/conf" # allowing saving to the same path as the game
export XDG_CONFIG_HOME="$GAMEDIR/conf"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CONFIG_HOME"

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

GAME_FILE="Spell Sling.exe"
LAUNCH_FILE="SpellSling"

if [ -f "$GAME_FILE" ]; then
  shaders_folder="shaders"
  shader_file="$shaders_folder/3d.frag"
  ./bin/7za x "$GAME_FILE" "$shader_file"
  sed -i 's/(1-/(1\.0-/g' "$shader_file"
  sed -i 's/a = 1;/a = 1\.0;/g' "$shader_file"
  sed -i 's/(1,/(1\.0,/g' "$shader_file"  
  sed -i 's/fogDist = 25;/fogDist = 25\.0;/' "$shader_file"
  sed -i 's/\/255,/\/255\.0,/g' "$shader_file"
  sed -i 's/uniform mat4/number/g' "$shader_file"
  sed -i 's/z == 0)/z == 0\.0)/g' "$shader_file"
  sed -i 's/x == 0 /x == 0\.0 /g' "$shader_file"
  sed -i 's/,1)/,1\.0)/g' "$shader_file"  
  
  ./bin/7za u -mx0 -aoa -y "$GAME_FILE" "$shader_file"
  rm -rf "$shaders_folder"
  
  patch_file="conf.lua"
  ./bin/7za x "$GAME_FILE" "$patch_file"
  sed -i 's/t/.window/.vsync = false/t/.window/.vsync = true/' "$patch_file"
  sed -i 's/height = 640/height = 0/' "$patch_file"
  sed -i 's/width = 640/width = 0/' "$patch_file"
  ./bin/7za u -mx0 -aoa -y "$GAME_FILE" "$patch_file"
  rm "$patch_file"
  
  patch_file="main.lua"
  ./bin/7za x "$GAME_FILE" "$patch_file"
  sed -i 's/setFullscreen(false)/setFullscreen(true)/' "$patch_file"  
  ./bin/7za u -mx0 -aoa -y "$GAME_FILE" "$patch_file"
  rm "$patch_file"
  
  mv "$GAME_FILE" "$LAUNCH_FILE"
fi

$GPTOKEYB "love" -c "spellsling.gptk" &
./bin/love "$LAUNCH_FILE"

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0