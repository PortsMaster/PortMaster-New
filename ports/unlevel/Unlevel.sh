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

source "$controlfolder/control.txt"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR="/$directory/ports/unlevel"
CONFDIR="$GAMEDIR/conf"

mkdir -p "$CONFDIR/love"
cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Verify the love_11.5 runtime is available; prompt the user to update PortMaster if not
runtime="love_11.5"
if [ ! -f "$controlfolder/runtimes/${runtime}/love.txt" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the love_11.5 runtime. Please update PortMaster from https://portmaster.games/"
    sleep 5
    exit 1
  fi
  $ESUDO "$controlfolder/harbourmaster" --quiet --no-check runtime_check "${runtime}.squashfs"
fi

# Patch .love once: replace keyboard hints and title background for gamepad
if [ -f "$GAMEDIR/gamedata/UnLevel.love" ] && [ ! -f "$GAMEDIR/gamedata/patched" ]; then
  pm_message "Patching game ..."
  sleep 2
  LOVE_FILE="$GAMEDIR/gamedata/Unlevel.love"
  PATCH_DIR="$GAMEDIR/gamedata/patch_tmp"
  mkdir -p "$PATCH_DIR"
  # Extract the LDtk world file from the .love archive
  unzip -o "$LOVE_FILE" ldtk/world.ldtk -d "$PATCH_DIR"
  # Apply gamepad hint replacements
  sed -i 's/Use -Spacebar- to tilt the level/Use -A\/B- to tilt the level/g' "$PATCH_DIR/ldtk/world.ldtk"
  sed -i 's/Press - Backspace - to restart/Press - L1\/L2 - to restart/g' "$PATCH_DIR/ldtk/world.ldtk"
  # Replace title background with the port's custom version
  mkdir -p "$PATCH_DIR/images"
  cp "$GAMEDIR/title_background.png" "$PATCH_DIR/images/title_background.png"
  # Update the .love archive with the patched files
  cd "$PATCH_DIR"
  zip -u "$LOVE_FILE" ldtk/world.ldtk images/title_background.png
  cd "$GAMEDIR"
  rm -rf "$PATCH_DIR"
  touch "$GAMEDIR/gamedata/patched"
fi

# Redirect save / config data into the port's conf folder
export XDG_DATA_HOME="$CONFDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"

# Load the LÖVE 11.5 runtime (sets $LOVE_BINARY, $LOVE_RUN, $LOVE_GPTK)
source "$controlfolder/runtimes/${runtime}/love.txt"

# gptokeyb acts as a kill-switch / hotkey helper; LÖVE handles SDL input natively
$GPTOKEYB "$LOVE_GPTK" -c "./unlevel.gptk" &

pm_platform_helper "$LOVE_BINARY"

$LOVE_RUN "$GAMEDIR/gamedata/Unlevel.love"

pm_finish
