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
export PORT_32BIT="N"
get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

GAMEDIR="/$directory/ports/gravitycircuit"
exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

# extract, diff
GAMEFILE="./gamedata/GravityCircuit.exe"
if [ -f "$GAMEFILE" ]; then
  # Replace with splashscreen?
  echo "Unpacking and patching game, this takes a while on the first start..." > /dev/tty0
  # unpack the game
  unzip -o "$GAMEFILE" -d ./gamedata 
  rm "$GAMEFILE"
  rm -Rf ./gamedata/platform
  cd ./gamedata
  # ungh, mixed line ends, there's probably a better way
  grep -E '^\+\+\+ ' "../gravitycircuit.diff" | sed -E 's/^\+\+\+ ([^\/]+\/)?//' | cut -f1 | xargs -I {} dos2unix "{}"
  # patch the unpacked game
  $GAMEDIR/bin/patch -p1 < "$GAMEDIR/gravitycircuit.diff"
fi

export XDG_DATA_HOME="$GAMEDIR/conf" # allowing saving to the same path as the game
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
mkdir -p "$XDG_DATA_HOME"

echo "Loading game.." > /dev/tty0

cd $GAMEDIR
$GPTOKEYB "love" -c gravitycircuit.gptk &
./bin/love ./gamedata

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
