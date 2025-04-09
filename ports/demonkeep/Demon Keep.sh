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

GAMEDIR="/$directory/ports/demonkeep"

export XDG_DATA_HOME="$GAMEDIR/conf" # allowing saving to the same path as the game
export XDG_CONFIG_HOME="$GAMEDIR/conf"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CONFIG_HOME"

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

GAME_NAME="DEMON KEEP"
GAME_FILE="$GAME_NAME.love"
LAUNCH_FILE="DEMONKEEP"

if [ -f "$GAME_NAME.exe" ]; then
  mv "$GAME_NAME.exe" "./$GAME_FILE"
fi

if [ -f "$GAME_FILE" ]; then
  patch_file="conf.lua"
  ./bin/7za x "$GAME_FILE" "$patch_file"
  sed -i 's/vsync = false/vsync = true/' "$patch_file"
  sed -i 's/t\.window\.height = 720/t\.window\.height = 0/' "$patch_file"
  sed -i 's/t\.window\.width = 1280/t\.window\.width = 0/' "$patch_file"
  ./bin/7za u -mx0 -aoa -y "$GAME_FILE" "$patch_file"
  rm "$patch_file"
  
  mv "$GAME_FILE" "$LAUNCH_FILE"
fi

$GPTOKEYB "love" -c "demonkeep.gptk" &
./bin/love "$LAUNCH_FILE"

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0