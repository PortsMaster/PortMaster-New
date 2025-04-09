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

GAMEDIR="/$directory/ports/dfencervstheorb"

export XDG_DATA_HOME="$GAMEDIR/conf" # allowing saving to the same path as the game
export XDG_CONFIG_HOME="$GAMEDIR/conf"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CONFIG_HOME"

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

game_name="love-jam-2023"
launch_file="$game_name"

if [ -f "$game_name.exe" ]; then
  game_file="$game_name.exe"
elif [ -f "$game_name.love" ]; then
  game_file="$game_name.love"
fi

if [ -f "$game_file" ]; then
  rm "$launch_file"  
	
  patch_file="shaders/hsv.fs"
  ./bin/7za x "$game_file" "$patch_file"
  sed -i 's/= 0)/= 0\.0)/' "$patch_file"
  ./bin/7za u -mx0 -aoa -y "$game_file" "$patch_file"
  rm -rf "shaders"
  
  patch_file="main.lua"
  ./bin/7za x "$game_file" "$patch_file"
  sed -i 's/love\.joystick\.loadGamepadMappings/--love\.joystick\.loadGamepadMappings/' "$patch_file"
  sed -i 's/love\.graphics\.print/--love\.graphics\.print/' "$patch_file"
  sed -i 's/scale = math\.floor/--scale = math\.floor/' "$patch_file"  
  ./bin/7za u -mx0 -aoa -y "$game_file" "$patch_file"
  rm "$patch_file"  
  
  ./bin/7za d "$game_file" "gamecontrollerdb.txt"
  
  mv "$game_file" "$launch_file"
fi

$GPTOKEYB "love" &
./bin/love "$launch_file"

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0