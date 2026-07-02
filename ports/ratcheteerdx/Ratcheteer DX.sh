#!/bin/bash
# PORTMASTER: ratcheteerdx.zip, Ratcheteer DX.sh

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

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

# Set directories
GAMEDIR=/$directory/ports/ratcheteerdx
DATADIR=$GAMEDIR/gamedata

LINUX_BINARY="RatcheteerDX"
MACOS_BINARY="RatcheteerDX.app/Contents/MacOS/RatcheteerDX"

cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [ -f "$DATADIR/RatcheteerDX-Demo" ]; then
  # if using Demo version mv to standard filename 
  echo "Using Linux version (demo)"
  mv "$DATADIR/RatcheteerDX-Demo" "$DATADIR/$LINUX_BINARY"
  GAMEMODE=box64

elif [ -f "$DATADIR/$LINUX_BINARY" ]; then
  echo "Using Linux version"
  GAMEMODE=box64

elif [ -f "$DATADIR/ratcheteer-dx-mac.zip" ]; then
  echo "Extracting RatcheteerDX.app"
  $ESUDO unzip -o -d "$DATADIR/" "$DATADIR/ratcheteer-dx-mac.zip" -x '*Frameworks*'
  rm -f "$DATADIR/ratcheteer-dx-mac.zip"

  echo "Using macOS version"
  GAMEMODE=machismo
elif [ -f "$DATADIR/$MACOS_BINARY" ]; then
  echo "Using macOS version"
  GAMEMODE=machismo
else
  pm_message "Game binary not found. Check your game files."
  sleep 10
  exit 1
fi

# Create XDG dirs and set permissions
export XDG_DATA_HOME="$GAMEDIR/savedata"
export MACHISMO_HOME="$GAMEDIR/savedata"
mkdir -p "$MACHISMO_HOME"

if [ ! -d "$XDG_DATA_HOME/com.panic.ratcheteerdx" ] && [ -d "$HOME/.local/share/com.panic.ratcheteerdx/" ]; then
  # Move the old incorrectly placed save files.
  cp -Rv "$HOME/.local/share/com.panic.ratcheteerdx" "$XDG_DATA_HOME"
fi

if [ "$GAMEMODE" = "machismo" ]; then
  # Setup machismo
  export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
  export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
  export MACHISMO_CONFIG="$GAMEDIR/conf/machismo.conf"

  MACHISMO_BIN="$GAMEDIR/gamedata/RatcheteerDX.app/Contents/Resources/machismo"

  if [ ! -f "$MACHISMO_BIN" ]; then
      cp -fv "$GAMEDIR/bin/machismo" "$MACHISMO_BIN"
  fi

  $GPTOKEYB "machismo" &
  pm_platform_helper "$MACHISMO_BIN" > /dev/null
  "$MACHISMO_BIN" "$DATADIR/$MACOS_BINARY"

  pm_finish

else
  # the default pulseaudio backend doesn't always work well
  if [[ "$CFW_NAME" = "ROCKNIX" ]] || [[ "$CFW_NAME" = "AmberELEC" ]]; then
    audio_backend=alsa
  fi

  $GPTOKEYB "$LINUX_BINARY" &
  $GAMEDIR/box64/box64 ./gamedata/$LINUX_BINARY

  pm_finish
fi
