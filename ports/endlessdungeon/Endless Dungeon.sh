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

GAMEDIR="/$directory/ports/endlessdungeon"

export XDG_DATA_HOME="$GAMEDIR/conf" # allowing saving to the same path as the game
export XDG_CONFIG_HOME="$GAMEDIR/conf"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CONFIG_HOME"

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

GAME_FILE_START="Endless Dungeon"
LAUNCH_FILE="endlessdungeon"

if [ -f "$GAME_FILE_START.exe" ]; then
  mv "$GAME_FILE_START.exe" $LAUNCH_FILE
elif [ -d "$GAME_FILE_START.app" ]; then
  mv "$GAME_FILE_START.app/Contents/Resources/$GAME_FILE_START.love" $LAUNCH_FILE
  rm -r "$GAME_FILE_START.app"
fi

$GPTOKEYB "love" -c endlessdungeon.gptk &
./bin/love $LAUNCH_FILE

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0