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

  # change some default settings
  sed -i 's/crt = 70,/crt = 0,/g' -i 's/bloom = 1/bloom = 0/g' globals.lua
  sed -i 's/s/shadows = 'On'/shadows = 'Off'/g' globals.lua
  sed -i 's/self.F_HIDE_BG = false/self.F_HIDE_BG = true/g' globals.lua

  if [ $DISPLAY_WIDTH -le 1279 ]; then # increase the scale for smaller screens
    sed -i 's/self.TILE_W = self.F_MOBILE_UI and 11.5 or 20/self.TILE_W = 18.25/g' globals.lua
    sed -i 's/self.TILE_H = self.F_MOBILE_UI and 20 or 11.5/self.TILE_H = 18.25/g' globals.lua
  fi

  if [ $DISPLAY_WIDTH -le 720 ]; then # switch out the font if the screen is too small; helping with readability
    cp resources/fonts/Nunito-Black.ttf resources/fonts/m6x11plus.ttf # change Nunito-Black to the in-game font file
    ./bin/7za u -aoa "$GAMEFILE" resources/fonts/m6x11plus.ttf
    rm resources/fonts/m6x11plus.ttf

    if [ $DISPLAY_HEIGHT -eq 720 ]; then # RGB30 specific changes
      mkdir -p ./functions
      ./bin/7za x "$GAMEFILE" functions/common_events.lua
      # move the hands a bit to the right
      sed -i 's/G.hand.T.x = G.TILE_W - G.hand.T.w - 2.85/G.hand.T.x = G.TILE_W - G.hand.T.w - 1/g' functions/common_events.lua
      # then move the playing area up
      sed -i 's/G.play.T.y = G.hand.T.y - 3.6/G.play.T.y = G.hand.T.y - 4.5/g' functions/common_events.lua
      # move the decks to the right
      sed -i 's/G.deck.T.x = G.TILE_W - G.deck.T.w - 0.5/G.deck.T.x = G.TILE_W - G.deck.T.w + 0.85/g' functions/common_events.lua
      # move the jokers to the left
      sed -i 's/G.jokers.T.x = G.hand.T.x - 0.1/G.jokers.T.x = G.hand.T.x - 0.15/g' functions/common_events.lua

      # Update the archive with the modified common_events.lua
      ./bin/7za u -aoa "$GAMEFILE" functions/common_events.lua
      rm functions/common_events.lua
    fi
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