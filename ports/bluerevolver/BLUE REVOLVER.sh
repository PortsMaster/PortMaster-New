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

GAMEDIR="/$directory/ports/bluerevolver"

export XDG_DATA_HOME="$GAMEDIR/conf" # allowing saving to the same path as the game
export XDG_CONFIG_HOME="$GAMEDIR/conf"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CONFIG_HOME"

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

game_name="bluerevolver"
launch_dir="gamedata"

if [ -f "$game_name.exe" ]; then
  game_file="$game_name.exe"
  expected_checksum="a96a0fbb0d85fadaf03fa70da202c8bb"
  patch_file="patch/bluerevolver.steam.win.patch"
elif [ -f "$game_name.love" ]; then
  game_file="$game_name.love"
  expected_checksum="2d30d20961e9859dc7b445269a77a179"
  patch_file="patch/bluerevolver.steam.linux.patch"
fi

if [ -f "$game_file" ]; then
  checksum=$(md5sum "$game_file" | awk '{print $1}')

  if [ "$checksum" != "$expected_checksum" ]; then
    echo "Invalid checksum: $game_file $checksum"
    exit 1
  fi

  if [ ! -f "$controlfolder/xdelta3" ]; then
    echo "xdelta3 not found"
    exit 1
  fi

  if [ -f "src.zip" ]; then
    rm "$patch_file"
    $controlfolder/xdelta3 -f -e -s "$game_file" "src.zip" "$patch_file"
  fi
  
  rm -rf "$launch_dir"
  patched_file="patched.zip"
  $ESUDO $controlfolder/xdelta3 -d -s "$game_file" -f "$patch_file" "$patched_file"
  $GAMEDIR/bin/7za x "$game_file" -o"$launch_dir" -y
  $GAMEDIR/bin/7za x "$patched_file" -o"$launch_dir" -y
  rm "$game_file"
  rm "$patched_file"
fi

$GPTOKEYB "love" -c "bluerevolver.gptk" &
./bin/love "$launch_dir"

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0