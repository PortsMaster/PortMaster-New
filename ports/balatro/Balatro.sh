#!/bin/bash
if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/device_info.txt
get_controls

GAMEDIR="/$directory/ports/balatro"
TILE_W="s/self.TILE_W = self.F_MOBILE_UI and 11.5 or 20/self.TILE_W = 16.5/g"
TILE_H="s/self.TILE_H = self.F_MOBILE_UI and 20 or 11.5/self.TILE_H = 16.5/g"
CRT="s/crt = 70,/crt = 0,/g"
SHADOWS="s/shadows = 'On'/shadows = 'Off'/g"
BLOOM="s/bloom = 1/bloom = 0/g"

export XDG_DATA_HOME="$GAMEDIR/saves"
export XDG_CONFIG_HOME="$GAMEDIR/saves"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

mkdir "$XDG_DATA_HOME"
cd $GAMEDIR

if [ -f "Balatro.exe" ]; then
    GAMEFILE="Balatro.exe"
elif [ -f "balatro.exe" ]; then
    GAMEFILE="balatro.exe"
elif [ -f "Balatro.love" ]; then
    GAMEFILE="Balatro.love"
elif [ -f "balatro.love" ]; then
    GAMEFILE="balatro.love"
fi

if [ -f "$GAMEFILE" ]; then
  # Extract globals.lua
  ./bin/7za x "$GAMEFILE" globals.lua

  # Modify globals.lua
  sed -i "$CRT" -i "$SHADOWS" -i "$BLOOM" globals.lua

  if [ $DISPLAY_WIDTH -le 1279 ]; then # increase the scale
      sed -i "$TILE_W" -i "$TILE_H" globals.lua
  fi

  if [ $DISPLAY_WIDTH -le 720 ]; then # switch out the font if the screen is too small; helping with readability
    cp resources/fonts/Nunito-Black.ttf resources/fonts/m6x11plus.ttf # change Nunito-Black to the in-game font file
    ./bin/7za u -aoa "$GAMEFILE" resources/fonts/m6x11plus.ttf
    rm resources/fonts/m6x11plus.ttf
  fi

  # Update the archive with the modified globals.lua
  ./bin/7za u -aoa "$GAMEFILE" globals.lua

  # Clean up
  mv $GAMEFILE Balatro
  rm globals.lua
fi


if [ -f "Balatro" ]; then
  $GPTOKEYB "love" -c "./balatro.gptk" &
  ./love Balatro
else
  echo "Balatro game file not found. Please drop in Balatro.exe or Balatro.love into the Balatro folder prior to starting the game."
fi

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0