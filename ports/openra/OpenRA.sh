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

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR=/$directory/ports/openra
CONFDIR=$GAMEDIR/conf
RUNDIR=$GAMEDIR/game
SRCDIR=$GAMEDIR/src
BINARY="OpenRA"

cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

echo "Device architecture is $DEVICE_ARCH"
echo "CFW name is $CFW_NAME"
echo "Glibc version is $CFW_GLIBC"
echo "Screen resolution $DISPLAY_WIDTH x $DISPLAY_HEIGHT"

# Check if display meets the minimum resolution requirements
if [ $DISPLAY_WIDTH -lt 640 ] || [ $DISPLAY_HEIGHT -lt 480 ]; then
  pm_message "This game requires a minimum resolution of 640x480, exiting"
  sleep 5
  exit 1
fi

# Check if the game is already installed, run the patch script otherwise
if [ ! -d "$RUNDIR" ]; then
  export PATCHER_FILE="$SRCDIR/patchscript"
  export PATCHER_TIME="3 minutes"

  if [ -f "$controlfolder/utils/patcher.txt" ]; then
    $ESUDO chmod a+x "$SRCDIR/patchscript"
    source "$controlfolder/utils/patcher.txt"
    $ESUDO kill -9 $(pidof gptokeyb)
  else
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi

  if [ ! -d "$RUNDIR" ]; then
    pm_message "Installation failed, please check the logs and the README for details."
  fi
fi

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

mkdir -p $CONFDIR
bind_directories ~/.config/openra "$CONFDIR"

# Set compatibility mode string
COMPATIBILITY_MODE=$CFW_NAME
if [ $CFW_NAME == "AeUX" ]; then
  # The R36 family is running ArkOS under the hood
  COMPATIBILITY_MODE="ArkOS"
fi

# ArkOS does not like the supplied freetype and openal libs
if [ "$COMPATIBILITY_MODE" == "ArkOS" ]; then
  cp /usr/lib/aarch64-linux-gnu/libopenal.so.1 "$RUNDIR"/soft_oal.so
  cp /usr/lib/aarch64-linux-gnu/libfreetype.so "$RUNDIR"/freetype6.so
fi

# Determine which UI yaml config set we need to use, depending on screen resolution
if [ $DISPLAY_WIDTH -lt 900 ]; then
  echo "Using low resolution UI"
  MODDIR="$SRCDIR"/mods_lowres
else
  echo "Using high resolution UI"
  MODDIR="$SRCDIR"/mods_highres
fi

# Update UI yaml configs to the set which works with the screen resolution
cd "$RUNDIR"/mods
for mod in *; do
  if [[ -d "$mod" ]]; then
    if [ -f "$MODDIR"/$mod/mod.yaml ]; then
      # update mod file
      rm -rf $mod/mod.yaml
      cp "$MODDIR"/$mod/mod.yaml $mod/mod.yaml
    fi
    if [[ $mod != *"content"* ]]; then
      if [[ -d "$MODDIR"/$mod/chrome ]]; then
        # update UI files
        rm -rf $mod/chrome
        cp -r "$MODDIR"/$mod/chrome $mod/chrome
      fi
      if [ -f "$MODDIR"/$mod/chrome.yaml ]; then
        # update chrome file
        rm -rf $mod/chrome.yaml
        cp "$MODDIR"/$mod/chrome.yaml $mod/chrome.yaml
      fi
    fi
  fi
done

# Run game selector
source $controlfolder/runtimes/"love_11.5"/love.txt
$GPTOKEYB "$LOVE_GPTK" &
pm_platform_helper "$LOVE_BINARY"
$LOVE_RUN $GAMEDIR
pm_gptokeyb_finish

GAMEMOD="$(cat selected_game)"
rm -rf "selected_game"
echo "Selected game $GAMEMOD"

# Update binaries for the selected game
cp "$SRCDIR"/mods_bin/openra/* "$RUNDIR"/
if [ -d "$SRCDIR"/mods_bin/$GAMEMOD ]; then
  cp "$SRCDIR"/mods_bin/$GAMEMOD/* "$RUNDIR"/
fi

# Start the game
cd "$RUNDIR"
$GPTOKEYB2 "$BINARY" -c "$GAMEDIR/openra.ini" >/dev/null &

pm_platform_helper "$BINARY" >/dev/null

./$BINARY Game.CompatibilityMode=$COMPATIBILITY_MODE Game.Mod=$GAMEMOD

pm_finish
