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

GAMEDIR="/$directory/ports/balatro"

export XDG_DATA_HOME="$GAMEDIR/saves" # allowing saving to the same path as the game
export XDG_CONFIG_HOME="$GAMEDIR/saves"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CONFIG_HOME"

## Uncomment the following file to log the output, for debugging purpose
# exec > >(tee "$GAMEDIR/log.txt") 2>&1

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
  ./bin/7za.${DEVICE_ARCH} x "$GAMEFILE" globals.lua

  # Modify globals.lua

  # change some default settings
  sed -i 's/crt = 70,/crt = 0,/g' globals.lua
  sed -i 's/bloom = 1/bloom = 0/g' globals.lua
  sed -i 's/s/shadows = 'On'/shadows = 'Off'/g' globals.lua
  sed -i 's/self.F_HIDE_BG = false/self.F_HIDE_BG = true/g' globals.lua

  if [ $DISPLAY_WIDTH -le 1279 ]; then # increase the scale for smaller screens
    sed -i 's/self.TILE_W = self.F_MOBILE_UI and 11.5 or 20/self.TILE_W = 18.25/g' globals.lua
    sed -i 's/self.TILE_H = self.F_MOBILE_UI and 20 or 11.5/self.TILE_H = 18.25/g' globals.lua
  fi

  if [ $DISPLAY_WIDTH -le 720 ]; then # switch out the font if the screen is too small; helping with readability
    cp resources/fonts/Nunito-Black.ttf resources/fonts/m6x11plus.ttf # change Nunito-Black to the in-game font file
    ./bin/7za.${DEVICE_ARCH} u -aoa "$GAMEFILE" resources/fonts/m6x11plus.ttf
    rm resources/fonts/m6x11plus.ttf
  fi

  # Update the archive with the modified globals.lua
  ./bin/7za.${DEVICE_ARCH} u -aoa "$GAMEFILE" globals.lua

  # CP the file to Patched Balatro location
  cp $GAMEFILE Balatro

  # RGB30 & Other 1x1 square ratio device specific changes
  if [ $DISPLAY_HEIGHT -eq $DISPLAY_WIDTH ]; then
    mkdir -p ./functions
    ./bin/7za.${DEVICE_ARCH} x "$GAMEFILE" functions/common_events.lua
    # move the hands a bit to the right
    sed -i 's/G.hand.T.x = G.TILE_W - G.hand.T.w - 2.85/G.hand.T.x = G.TILE_W - G.hand.T.w - 1/g' functions/common_events.lua
    # then move the playing area up
    sed -i 's/G.play.T.y = G.hand.T.y - 3.6/G.play.T.y = G.hand.T.y - 4.5/g' functions/common_events.lua
    # move the decks to the right
    sed -i 's/G.deck.T.x = G.TILE_W - G.deck.T.w - 0.5/G.deck.T.x = G.TILE_W - G.deck.T.w + 0.85/g' functions/common_events.lua
    # move the jokers to the left
    sed -i 's/G.jokers.T.x = G.hand.T.x - 0.1/G.jokers.T.x = G.hand.T.x - 0.2/g' functions/common_events.lua

    # Update the archive with the modified common_events.lua
    ./bin/7za.${DEVICE_ARCH} u -aoa "$GAMEFILE" functions/common_events.lua
    rm functions/common_events.lua
    cp $GAMEFILE Balatro_1x1
  fi

  rm $GAMEFILE
  rm globals.lua
fi

if [ "${DEVICE_NAME}" = "TrimUI Smart Pro" ]; then
  # These libs are no good.
  LIBDIR="$GAMEDIR/libs.${DEVICE_ARCH}"

  if [ -f "$LIBDIR/libfontconfig.so.1" ]; then
    $ESUDO rm -f "$LIBDIR/libfontconfig.so.1"
  fi

  if [ -f "$LIBDIR/libtheoradec.so.1" ]; then
    $ESUDO rm -f "$LIBDIR/libtheoradec.so.1"
  fi
fi

LAUNCH_GAME="Balatro"

if [ $DISPLAY_HEIGHT -eq $DISPLAY_WIDTH ]; then
  LAUNCH_GAME="Balatro_1x1"
fi

if [ -f "$LAUNCH_GAME" ]; then
  $GPTOKEYB "love.${DEVICE_ARCH}" &
  ./bin/love.${DEVICE_ARCH} "$LAUNCH_GAME"
else
  echo "Balatro game file not found. Please drop in Balatro.exe or Balatro.love into the Balatro folder prior to starting the game."
fi

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0