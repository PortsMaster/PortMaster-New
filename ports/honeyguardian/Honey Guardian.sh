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

GAMEDIR="/$directory/ports/honeyguardian"

export XDG_DATA_HOME="$GAMEDIR/conf" # allowing saving to the same path as the game
export XDG_CONFIG_HOME="$GAMEDIR/conf"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CONFIG_HOME"

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

win_game_file="Honey Guardian.exe"
linux_game_file="honey-guardian.love"
launch_file="honeyguardian.game"

if [ -f "$win_game_file" ]; then
  game_file="$win_game_file"
elif [ -f "$linux_game_file" ]; then
  game_file="$linux_game_file"
fi

if [ -f "$game_file" ]; then
  patch_dir="code"
  patch_file="$patch_dir/System/Config.lua"
  ./bin/7za x "$game_file" "$patch_file"
  sed -i 's/fullscreen = false/fullscreen = true/' "$patch_file"
  sed -i 's/vsync = false/vsync = true/' "$patch_file"
  sed -i 's/canvasscaleint = true/canvasscaleint = false/' "$patch_file"
  ./bin/7za u -mx0 -aoa -y "$game_file" "$patch_file"
  rm -rf "$patch_dir"

  mv "$game_file" "$launch_file"
fi

$GPTOKEYB "love" &
./bin/love "$launch_file"

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0