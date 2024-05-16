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

GAMEDIR="/$directory/ports/fungusreaper"

export XDG_DATA_HOME="$GAMEDIR/conf" # allowing saving to the same path as the game
export XDG_CONFIG_HOME="$GAMEDIR/conf"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CONFIG_HOME"

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

GAME_FILE="FungusReaper.exe"
LAUNCH_FILE="FungusReaper"

if [ -f "$GAME_FILE" ]; then
  shaders_folder="shaders"
  shader_file="$shaders_folder/distortionShader.fs"
  ./bin/7za x "$GAME_FILE" "$shader_file"
  sed -i 's/number/float/' "$shader_file"
  sed -i 's/ = 0.06//' "$shader_file"
  sed -i 's/100/100\.0/' "$shader_file"
  sed -i 's/.03/0\.03/' "$shader_file"
  shader_file="$shaders_folder/scanLinesShader.fs"
  ./bin/7za x "$GAME_FILE" "$shader_file"
  sed -i 's/extern //g' "$shader_file"
  sed -i 's/number time/extern float time/g' "$shader_file"
  sed -i 's/\.f/\.0/g' "$shader_file"
  sed -i 's/3\.14f/3\.14/' "$shader_file"  
  sed -i 's/35f/35/' "$shader_file"
  sed -i 's/\.07f + 0\.94f/0\.07 + 0\.94/' "$shader_file"
  sed -i 's/\.03f/0\.03/' "$shader_file"
  sed -i 's/0\.95f/0\.95/g' "$shader_file"
  shader_file="$shaders_folder/vingetteShader.fs"
  ./bin/7za x "$GAME_FILE" "$shader_file"
  sed -i 's/extern float strength = 0\.07f/float strength = 0\.07/' "$shader_file"
  sed -i 's/\.5/0\.5/' "$shader_file"
  sed -i 's/0, 1/0\.0, 0\.1/' "$shader_file"  
  ./bin/7za u -mx0 -aoa -y "$GAME_FILE" "$shaders_folder"/*
  rm -rf "$shaders_folder"
  shader_file="$shaders_folder/spinShader.fs"
  ./bin/7za x "$GAME_FILE" "$shader_file"
  sed -i 's/number/float/' "$shader_file"
  sed -i 's/ = 0\.06//' "$shader_file"
  sed -i 's/100/100\.0/' "$shader_file"
  sed -i 's/\.03/0\.03/' "$shader_file" 
  ./bin/7za u -mx0 -aoa -y "$GAME_FILE" "$shaders_folder"/*
  rm -rf "$shaders_folder"
  
  mainlua_file="main.lua"
  ./bin/7za x "$GAME_FILE" "$mainlua_file"
  sed -i 's/pixelperfect = true/pixelperfect = false/' "$mainlua_file"
  ./bin/7za u -mx0 -aoa -y "$GAME_FILE" "$mainlua_file"
  rm "$mainlua_file"
  
  patch_file="help/utils.lua"
  ./bin/7za x "$GAME_FILE" "$patch_file"
  sed -i '/drawInput(isPrimary, x, y, opacity, scale)/a \  local rotation = 0' "$patch_file"
  sed -i '/local rotation = 0/a \  if isPrimary then rotation = math.rad(-90) else rotation = math.rad(90) end' "$patch_file"
  sed -i 's/0, inputScale,/rotation, inputScale,/' "$patch_file"
  ./bin/7za u -mx0 -aoa -y "$GAME_FILE" "$patch_file"
  rm "$patch_file"
  
  mv "$GAME_FILE" "$LAUNCH_FILE"
fi

$GPTOKEYB "love" &
./bin/love $LAUNCH_FILE

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0