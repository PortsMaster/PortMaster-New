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

GAMEDIR="/$directory/ports/absolutereflex"

export XDG_DATA_HOME="$GAMEDIR/conf" # allowing saving to the same path as the game
export XDG_CONFIG_HOME="$GAMEDIR/conf"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CONFIG_HOME"

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

game_name="AbsoluteReflex-0.7"
launch_file="$game_name"

if [ -f "$game_name.exe" ]; then
  game_file="$game_name.exe"
elif [ -f "$game_name.love" ]; then
  game_file="$game_name.love"
fi

if [ -f "$game_file" ]; then
  rm "$launch_file"  
	
  patch_file="objects/mouse.lua"
  ./bin/7za x "$game_file" "$patch_file"
  sed -i 's/self:draw_sprite()/love\.graphics\.draw(self\.sprite, self\.x-14, self\.y-12)/' "$patch_file"
  sed -i 's/self\.x, self\.y/--self\.x, self\.y/' "$patch_file"
  sed -i "/update(self, dt)/a \	if camera.width > camera.mouse.x then self.x = camera.mouse.x end" $patch_file  
  sed -i "/update(self, dt)/a \	if camera.height > camera.mouse.y then self.y = camera.mouse.y end" $patch_file
  ./bin/7za u -mx0 -aoa -y "$game_file" "$patch_file"
  rm "$patch_file"
  
  patch_file="patch/conf.lua"
  cp "patch/$patch_file" "$patch_file"
  ./bin/7za u -mx0 -aoa -y "$game_file" "$patch_file"
  rm "conf.lua"
  
  patch_file="game/init.lua"
  ./bin/7za x "$game_file" "$patch_file"
  sed -i 's/glsl3/glsl1/' "$patch_file"
  sed -i 's/= texture(/= texture2D(/g' "$patch_file"
  ./bin/7za u -mx0 -aoa -y "$game_file" "$patch_file"
  rm -rf "game"
  
  patch_file="algtuup/camera.lua"
  ./bin/7za x "$game_file" "$patch_file"
  sed -i 's/stretch = false/stretch = true/' "$patch_file"
  ./bin/7za u -mx0 -aoa -y "$game_file" "$patch_file"
  rm -rf "algtuup"  
  
  patch_file="game/rooms/room_title.lua"
  ./bin/7za x "$game_file" "$patch_file"
  sed -i 's/Full Screen/Toggle Aspect Ratio/' "$patch_file"
  sed -i 's/window\.toggle_fullscreen()/if camera\.canvas\.stretch then camera\.canvas\.stretch = false else camera\.canvas\.stretch = true end camera:window_changed()/' "$patch_file"  
  ./bin/7za u -mx0 -aoa -y "$game_file" "$patch_file"
  rm -rf "game"
  
  mv "$game_file" "$launch_file"
fi

$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "love" -c "absolutereflex.gptk" &
./bin/love "$launch_file"

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0