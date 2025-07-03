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

GAMEDIR=/$directory/ports/jaggedalliance2
CONFDIR=$GAMEDIR/conf
TOOLDIR=$GAMEDIR/tools
BINDIR=$GAMEDIR/bin
RUNDIR=$GAMEDIR/game
BINARY="AppRun"

cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Check if the game is already installed, run the patch script otherwise
if [ ! -f "$RUNDIR/ja2.exe" ] || [ ! -f "$BINDIR/$BINARY" ]; then
  export PATCHER_FILE="$TOOLDIR/patchscript"
  export PATCHER_TIME="2-5 minutes"

  if [ -f "$controlfolder/utils/patcher.txt" ]; then
    $ESUDO chmod a+x "$TOOLDIR/patchscript"
    source "$controlfolder/utils/patcher.txt"
    $ESUDO kill -9 $(pidof gptokeyb)
  else
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
  fi

  if [ ! -f "$RUNDIR/ja2.exe" ] || [ ! -f "$BINDIR/$BINARY" ]; then
    pm_message "Installation failed, please check the logs and the README for details."
  fi
else
  echo "Extraction process already completed. Skipping."
fi

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Ensure the conf directory exists
mkdir -p $CONFDIR
bind_directories ~/.ja2 "$CONFDIR"

# Check if display meets the minimum resolution requirements
echo "Display resolution is $DISPLAY_WIDTH x $DISPLAY_HEIGHT"
if [ $DISPLAY_WIDTH -lt 640 ] || [ $DISPLAY_HEIGHT -lt 480 ]; then
  pm_message "This game requires a minimum resolution of 640x480, exiting"
  exit 1
fi

# Create game settings file with resolution and scaling that are appropriate for the display
ASPECT_RATIO="$ASPECT_X:$ASPECT_Y"
echo "Display aspect ratio is $ASPECT_RATIO"
case $ASPECT_RATIO in
  "16:10" | "16:9" | "5:3")
    SETTINGS=$(printf '{ "game_dir": "%s", "scaling": "NEAR_PERFECT" }' "$RUNDIR")
    ;;

  "3:2" | "1:1")
    SETTINGS=$(printf '{ "game_dir": "%s", "res": "%sx%s" }' "$RUNDIR" "$DISPLAY_WIDTH" "$DISPLAY_HEIGHT")
    ;;

  *)
    # 4:3 and everything else
    SETTINGS=$(printf '{ "game_dir": "%s" }' "$RUNDIR")
    ;;
esac

echo "Using settings '$SETTINGS'"
echo "$SETTINGS" > $CONFDIR/ja2.json

$GPTOKEYB2 "ja2" -c "ja2.ini" >/dev/null &

pm_platform_helper "$BINARY" >/dev/null

$BINDIR/$BINARY

pm_finish
