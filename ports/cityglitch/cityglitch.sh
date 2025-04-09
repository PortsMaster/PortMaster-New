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

GAMEDIR="/$directory/ports/cityglitch"

export XDG_DATA_HOME="$GAMEDIR/conf" # allowing saving to the same path as the game
export XDG_CONFIG_HOME="$GAMEDIR/conf"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CONFIG_HOME"

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

game_name="cityglitch"
launch_file="cityglitch"

if [ -f "$game_name.exe" ]; then
  game_file="$game_name.exe"
elif [ -f "$game_name.love" ]; then
  game_file="$game_name.love"
fi

if [ -f "$game_file" ]; then
  rm "$launch_file"

  input_dir="data/images"
  output_dir="$input_dir/converted"
  mkdir -p "$output_dir"
  ./bin/7za x "$game_file" "$input_dir"
  for file in "$input_dir"/*.png; do
    filename=$(basename "$file")
	echo "$filename.." > /dev/tty0
    ./bin/ffmpeg -i "$file" -pix_fmt rgba "$output_dir/$filename"
  done
  mv -f "$output_dir"/* "$input_dir"  
  ./bin/7za u -mx0 -aoa -y "$game_file" "$input_dir"/*  
  rm -rf "data"
  
  mouse_file="left_ptr.png"
  cp "patch/$mouse_file" "$mouse_file"
  ./bin/7za u -mx0 -aoa -y "$game_file" "$mouse_file"
  rm "$mouse_file"

  patch_file="util/Application.lua"
  ./bin/7za x "$game_file" "$patch_file"
  sed -i "1i cursorImage = love.graphics.newImage('left_ptr.png')" $patch_file
  sed -i '2i function drawCursor()' "$patch_file"
  sed -i '3i\  local mouseX, mouseY = love.mouse.getPosition()' "$patch_file"
  sed -i '4i\  love.graphics.setColor(1,1,1)' "$patch_file"
  sed -i '5i\  love.graphics.draw(cursorImage, mouseX, mouseY)' "$patch_file"
  sed -i '6i end' "$patch_file"
  sed -i '7i love.mouse.setVisible(false)' "$patch_file"
  sed -i "/self:draw_to_target (nil)/a \  drawCursor()" $patch_file  
  ./bin/7za u -mx0 -aoa -y "$game_file" "$patch_file"
  
  patch_file="util/Color.lua"
  ./bin/7za x "$game_file" "$patch_file"
  sed -i "s/setColor(255,255,255,255)/setColor(1,1,1,1)/" "$patch_file"  
  ./bin/7za u -mx0 -aoa -y "$game_file" "$patch_file"
  
  patch_file="util/init_standard_controls.lua"
  ./bin/7za x "$game_file" "$patch_file"
  sed -i "s/s:encode/--s:encode/" "$patch_file"
  sed -i "s/newScreenshot()/captureScreenshot(file_name..'\.png')/" "$patch_file"
  ./bin/7za u -mx0 -aoa -y "$game_file" "$patch_file"  

  rm -rf "util"

  mv "$game_file" "$launch_file"
fi

$GPTOKEYB "love" -c "cityglitch.gptk" &
./bin/love "$launch_file"

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0