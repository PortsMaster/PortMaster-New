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

GAMEDIR="/$directory/ports/depthsoflimbo"

export XDG_DATA_HOME="$GAMEDIR/conf" # allowing saving to the same path as the game
export XDG_CONFIG_HOME="$GAMEDIR/conf"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CONFIG_HOME"

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

game_name="DepthsOfLimbo"
launch_dir="gamedata"

if [ -f "$game_name.exe" ]; then
  game_file="$game_name.exe"
  patch_file="patch/DepthsOfLimbo.win.patch"
elif [ -f "$game_name.love" ]; then
  game_file="$game_name.love"
  patch_file="patch/DepthsOfLimbo.linux.patch"
fi

if [ -f "$game_file" ]; then 
  patched_file="patched.zip"
  if [ -f "src.zip" ]; then
    rm "$patch_file"
    $controlfolder/xdelta3 -f -e -s "$game_file" "src.zip" "$patch_file"
  fi
  $ESUDO $controlfolder/xdelta3 -d -s "$game_file" -f "$patch_file" "$patched_file"
  $GAMEDIR/bin/7za x "$game_file" -o"$launch_dir" -y
  $GAMEDIR/bin/7za x "$patched_file" -o"$launch_dir" -y
  rm "$game_file"
  rm "$patched_file"
fi

input_file="$launch_dir/input.lua"

if [ "$ANALOG_STICKS" -lt "2" ]; then
  sed -i 's/gamepad_enabled = true/gamepad_enabled = false/' "$input_file"
  gptk_args="-c depthsoflimbo.gptk"
else 
  sed -i 's/gamepad_enabled = false/gamepad_enabled = true/' "$input_file"
  gptk_args=""
fi

$GPTOKEYB "love" $gptk_args &
$GAMEDIR/bin/love "$launch_dir"

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0