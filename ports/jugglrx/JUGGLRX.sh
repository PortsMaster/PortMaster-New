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

GAMEDIR="/$directory/ports/jugglrx"

export XDG_DATA_HOME="$GAMEDIR/conf" # allowing saving to the same path as the game
export XDG_CONFIG_HOME="$GAMEDIR/conf"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CONFIG_HOME"

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

GAME_FILE="JUGGLRX.exe"
LAUNCH_FILE="JUGGLRX"

if [ -f "$GAME_FILE" ]; then
  patch_file="main.lua"
  ./bin/7za x "$GAME_FILE" "$patch_file"
  sed -i 's/window_width = 480 \* 3/window_width = "max"/' "$patch_file"
  sed -i 's/window_height = 270 \* 3/window_height = "max"/' "$patch_file"
  sed -i '/set_mouse_grabbed(true)/a \  love.mouse.setVisible(false)' "$patch_file"  
  ./bin/7za u -mx0 -aoa -y "$GAME_FILE" "$patch_file"
  rm "$patch_file"
  
  patch_file="engine/external/init.lua"
  ./bin/7za x "$GAME_FILE" "$patch_file"
  sed -i 's/if not web/--if not web/' "$patch_file"
  ./bin/7za u -mx0 -aoa -y "$GAME_FILE" "$patch_file"
  rm -rf "engine"

  mv "$GAME_FILE" "$LAUNCH_FILE"
fi

$GPTOKEYB "love" -c "jugglrx.gptk" &
./bin/love "$LAUNCH_FILE"

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0