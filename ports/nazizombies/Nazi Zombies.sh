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

GAMEDIR=/$directory/ports/nazizombies
TOOLDIR=$GAMEDIR/tools
RUNDIR=$GAMEDIR/game
BINARY="nzp-sdl"

cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Check if the game is already installed, run the patch script otherwise
if [ ! -f "$RUNDIR/$BINARY" ]; then
  export PATCHER_FILE="$TOOLDIR/patchscript"
  export PATCHER_TIME="2 minutes"

  if [ -f "$controlfolder/utils/patcher.txt" ]; then
    $ESUDO chmod a+x "$TOOLDIR/patchscript"
    source "$controlfolder/utils/patcher.txt"
    $ESUDO kill -9 $(pidof gptokeyb)
  else
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
  fi

  if [ ! -f "$RUNDIR/$BINARY" ]; then
    pm_message "Installation failed, please check the logs and the README for details."
  fi
else
  pm_message "Game files found. Skipping."
fi

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Update game settings file with screen resolution
if [ -f "$RUNDIR/nzp/user_settings.cfg" ]; then
  CONFIGFILE="$RUNDIR"/nzp/user_settings.cfg
else
  CONFIGFILE="$RUNDIR"/nzp/nzportable.cfg
fi
sed -i -E "s/vid_width.*/vid_width \"$DISPLAY_WIDTH\"/" $CONFIGFILE
sed -i -E "s/vid_height.*/vid_height \"$DISPLAY_HEIGHT\"/" $CONFIGFILE
sed -i -E "s/vid_conwidth.*/vid_conwidth \"$DISPLAY_WIDTH\"/" $CONFIGFILE
sed -i -E "s/vid_conheight.*/vid_conheight \"$DISPLAY_HEIGHT\"/" $CONFIGFILE

cd "$RUNDIR"

$GPTOKEYB2 "$BINARY" -c "$GAMEDIR/nzp.ini" >/dev/null &

pm_platform_helper "$BINARY" >/dev/null

./$BINARY

pm_finish
