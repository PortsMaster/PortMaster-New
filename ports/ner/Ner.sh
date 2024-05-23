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

GAMEDIR="/$directory/ports/ner"

export XDG_DATA_HOME="$GAMEDIR/conf" # allowing saving to the same path as the game
export XDG_CONFIG_HOME="$GAMEDIR/conf"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CONFIG_HOME"

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

GAME_FILE="Ner.love"
LAUNCH_FILE="Ner"

if [ -f "$GAME_FILE" ]; then
  shaders_folder="shaders"
  shader_file="$shaders_folder/3d.frag"
  ./bin/7za x "$GAME_FILE" "$shader_file"  
  sed -i 's/-1;/-1.0;/g' "$shader_file"
  sed -i 's/(1-/(1\.0-/g' "$shader_file"
  sed -i 's/a = 1;/a = 1\.0;/g' "$shader_file"
  sed -i 's/(1,/(1\.0,/g' "$shader_file"  
  sed -i 's/fogDist = 25;/fogDist = 25\.0;/' "$shader_file"
  sed -i 's/\/255,/\/255\.0,/g' "$shader_file"
  sed -i 's/uniform mat4/number/g' "$shader_file"
  sed -i 's/\/32;/\/32\.0;/g' "$shader_file"
  sed -i 's/texRes = 32;/texRes = 32\.0;/g' "$shader_file"
  sed -i 's/lightValue = 0;/lightValue = 0\.0;/g' "$shader_file"
  sed -i 's/Dot = 1;/Dot = 1\.0;/g' "$shader_file"
  sed -i 's/Dot > 0 /Dot > 0\.0 /g' "$shader_file"
  sed -i 's/flooredWorldPosition, 0)-0\.5) \/ 32;/flooredWorldPosition, 0\.0)-0\.5) \/ 32\.0;/g' "$shader_file"
  sed -i 's/lightValue = 1;/lightValue = 1\.0;/g' "$shader_file"
  sed -i 's/lightValue <= 0)/lightValue <= 0\.0)/g' "$shader_file"
  sed -i 's/lightValue <= 0)/lightValue <= 0\.0)/g' "$shader_file"
  sed -i 's/float i=0;/float i=0\.0;/g' "$shader_file"
  sed -i 's/i=0\.0;i<1;/i=0\.0;i<1\.0;/g' "$shader_file"
  sed -i 's/i,1-lightValue/i,1\.0-lightValue/g' "$shader_file"  
  
  shader_file="$shaders_folder/shader_compass.frag"
  ./bin/7za x "$GAME_FILE" "$shader_file"
  sed -i 's/\*40)/\*40\.0)/g' "$shader_file"
  sed -i 's/\/255,/\/255\.0,/g' "$shader_file"
  sed -i 's/\/255)/\/255\.0)/g' "$shader_file"  
  sed -i 's/\/32)/\/32\.0)/g' "$shader_file"
  sed -i 's/time\*8)/time\*8\.0)/' "$shader_file"
  sed -i 's/time\*4)/time\*4\.0)/' "$shader_file"  
  
  shader_file="$shaders_folder/shader_ghost.frag"
  ./bin/7za x "$GAME_FILE" "$shader_file"
  sed -i 's/\*5;/\*5\.0;/g' "$shader_file"
  sed -i 's/a == 0)/a == 0\.0)/g' "$shader_file"
  sed -i 's/\/255,/\/255\.0,/g' "$shader_file"
  sed -i 's/\/255)/\/255\.0)/g' "$shader_file"
  
  ./bin/7za u -mx0 -aoa -y "$GAME_FILE" "$shaders_folder"/*
  rm -rf "$shaders_folder"
  
  patch_file="conf.lua"
  ./bin/7za x "$GAME_FILE" "$patch_file"
  sed -i 's/vsync = false/vsync = true/' "$patch_file"
  sed -i 's/height = 720/height = 0/' "$patch_file"
  sed -i 's/height = 1280/height = 0/' "$patch_file"
  ./bin/7za u -mx0 -aoa -y "$GAME_FILE" "$patch_file"
  rm "$patch_file"
  
  patch_file="bin/WorldBuilder.lua"
  ./bin/7za x "$GAME_FILE" "$patch_file"
  sed -i 's/modelQuality = "medium"/modelQuality = "low"/' "$patch_file"
  ./bin/7za u -mx0 -aoa -y "$GAME_FILE" "$patch_file"
  rm "$patch_file"
  
  patch_file="bin/Screen.lua"
  ./bin/7za x "$GAME_FILE" "$patch_file"
  sed -i 's/384,216/192,108/' "$patch_file"
  ./bin/7za u -mx0 -aoa -y "$GAME_FILE" "$patch_file"
  rm "$patch_file"
  
  patch_file="main.lua"
  ./bin/7za x "$GAME_FILE" "$patch_file"
  sed -i 's/setFullscreen(false)/setFullscreen(true)/' "$patch_file" 
  if ! grep -q "getFPS" "$patch_file"; then
    sed -i '/fileHandler:drawScripts()/a \	lg.print(""..tostring(love.timer.getFPS( )), 10, 10)' "$patch_file" 
  fi
  ./bin/7za u -mx0 -aoa -y "$GAME_FILE" "$patch_file"
  rm "$patch_file"
  
  mv "$GAME_FILE" "$LAUNCH_FILE"
fi

$GPTOKEYB "love" -c "ner.gptk" &
./bin/love "$LAUNCH_FILE"

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0