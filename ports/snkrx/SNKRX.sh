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

GAMEDIR="/$directory/ports/snkrx"

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

GAME_FILE="SNKRX.exe"
LAUNCH_FILE="SNKRX"

if [ -f "$GAME_FILE" ]; then
  echo "Patching game.." > /dev/tty0
  
  MOUSE_FILE="left_ptr.png"
  cp "patch/$MOUSE_FILE" "$MOUSE_FILE"
  ./bin/7za u -aoa -y "$GAME_FILE" "$MOUSE_FILE"
  rm "$MOUSE_FILE"
  
  engine_dir="engine"
  mkdir -p "./$engine_dir"
  cp -rf "./patch/$engine_dir"/* "$engine_dir"
  ./bin/7za u -mx0 -aoa -y "$GAME_FILE" "$engine_dir"/*
  rm -rf "$engine_dir"  
  for file in "./patch"/*.lua; do   
    filename=$(basename "$file") # Get the filename without the directory path
	cp "./patch/$filename" "./"
   ./bin/7za u -mx0 -aoa -y "$GAME_FILE" "$filename"
    rm "$filename"
  done
  
  echo "Compressing assets.." > /dev/tty0
  
  input_dir="assets/sounds"
  output_dir="assets/sounds/compressed"
  mkdir -p "$output_dir"
  ./bin/7za x "$GAME_FILE" "$input_dir"

  for file in "$input_dir"/*.ogg; do
    # Get the filename without the directory path
    filename=$(basename "$file")
	echo "$filename.." > /dev/tty0
   ./bin/ffmpeg -i "$file" -acodec libvorbis -q:a 0 -ab 32k -ar 22050 -y "$output_dir/$filename"
  done

  mv -f "$output_dir"/* "$input_dir"  
  ./bin/7za u -mx0 -aoa -y "$GAME_FILE" "$input_dir"/*
  rm -rf "assets"
  
  mv "$GAME_FILE" "$LAUNCH_FILE"
fi

export XDG_DATA_HOME="$GAMEDIR/conf" # allowing saving to the same path as the game
export XDG_CONFIG_HOME="$GAMEDIR/conf"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CONFIG_HOME"

echo "Loading game.." > /dev/tty0

$GPTOKEYB "love" -c snkrx.gptk &
./bin/love $LAUNCH_FILE

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
