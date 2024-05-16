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

GAMEDIR="/$directory/ports/spelltower"

export XDG_DATA_HOME="$GAMEDIR/conf" # allowing saving to the same path as the game
export XDG_CONFIG_HOME="$GAMEDIR/conf"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CONFIG_HOME"

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

GAME_NAME="Spell Tower"
GAME_FILE="$GAME_NAME.love"
LAUNCH_FILE="$GAME_NAME"
ARCHIVE_FILE="$GAME_NAME.zip"

if [ -f "$ARCHIVE_FILE" ]; then
  exe_file="$GAME_NAME/$GAME_NAME.exe"
  ./bin/7za x "$ARCHIVE_FILE" "$exe_file"
  mv "$exe_file" "$GAME_FILE"
  rm -rf "$GAME_NAME"
  rm "$ARCHIVE_FILE"
fi

if [ -f "$GAME_NAME.exe" ]; then
  mv "$GAME_NAME.exe" "./$GAME_FILE"
fi

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
  
  ./bin/7za u -mx0 -aoa -y "$GAME_FILE" "$shader_file"
  rm -rf "$shaders_folder"
  
  patch_file="conf.lua"
  ./bin/7za x "$GAME_FILE" "$patch_file"
  sed -i 's/vsync = false/vsync = true/' "$patch_file"
  sed -i 's/t\.window\.height = 720/t\.window\.height = 0/' "$patch_file"
  sed -i 's/t\.window\.width = 1280/t\.window\.width = 0/' "$patch_file"
  ./bin/7za u -mx0 -aoa -y "$GAME_FILE" "$patch_file"
  rm "$patch_file"
  
  patch_file="main.lua"
  ./bin/7za x "$GAME_FILE" "$patch_file"
  sed -i 's/setFullscreen(false)/setFullscreen(true)/' "$patch_file"  
  sed -i 's/function love\.update(dt)/function update(dt)/' "$patch_file"
  sed -i 's/min(dt, 1 \/ 30)/dt/' "$patch_file"
  sed -i '/fileHandler:initScripts()/a\	if Menu.buttons == nil then Menu.buttons = {} end' "$patch_file"  
  echo "" >> $patch_file
  echo "function love.update(dt)" >> $patch_file
  echo "	local fixed_dt = 1/120" >> $patch_file
  echo "	local max_frame_skip = 30" >> $patch_file
  echo "	local max_dt_skip = fixed_dt*max_frame_skip" >> $patch_file
  echo "	local lag = accumulator + dt" >> $patch_file  
  echo "	if lag > max_dt_skip then accumulator = max_dt_skip else accumulator = lag end" >> $patch_file
  echo "	while accumulator >= fixed_dt do" >> $patch_file
  echo "		update(fixed_dt)" >> $patch_file
  echo "		accumulator = accumulator - fixed_dt" >> $patch_file
  echo "	end" >> $patch_file
  echo "end" >> $patch_file    
  echo "accumulator = 0" >> $patch_file  
  ./bin/7za u -mx0 -aoa -y "$GAME_FILE" "$patch_file"
  rm "$patch_file"
  
  patch_file="bin/Hud.lua"
  ./bin/7za x "$GAME_FILE" "$patch_file"
  sed -i '/self.scale = 3/a\	self.cursorScale = 2' "$patch_file"
  sed -i '/self.scale = 3/a\	if Screen.resolution[1] <= 480 then self.scale = 1 elseif Screen.resolution[1] >= 1920 then self.scale = 4 else self.scale = 2 end' "$patch_file"
  sed -i '/self.cursorScale = 2/a\	if Screen.resolution[1] <= 480 then self.cursorScale = 2 else self.cursorScale = self.scale end' "$patch_file"
  sed -i 's/Cursor\.pos\[2\], 0, self\.scale)/Cursor\.pos\[2\], 0, self\.cursorScale)/' "$patch_file"  
  ./bin/7za u -mx0 -aoa -y "$GAME_FILE" "$patch_file"
  rm "$patch_file"
  
  patch_file="bin/Card.lua"
  ./bin/7za x "$GAME_FILE" "$patch_file"
  sed -i 's/spacing = 40/spacing = 30/' "$patch_file"
  sed -i 's/speed = speed /--speed = speed /' "$patch_file"
  ./bin/7za u -mx0 -aoa -y "$GAME_FILE" "$patch_file"
  rm "$patch_file"
  
  mv "$GAME_FILE" "$LAUNCH_FILE"
fi

$GPTOKEYB "love" -c "spelltower.gptk" &
./bin/love "$LAUNCH_FILE"

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0