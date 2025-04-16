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

GAMEDIR=/$directory/ports/arx
CONFDIR="$GAMEDIR/conf/"
INSTALLDIR=$GAMEDIR/install
DATADIR=$GAMEDIR/gamedata
BINARY=arx

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

mkdir -p "$GAMEDIR/conf"

cd $GAMEDIR

export PATCHER_FILE="$GAMEDIR/tools/patchscript"
export PATCHER_TIME="2 minutes"

if [ ! -f "$DATADIR/data.pak" ] && [ ! -f "$DATADIR/DATA.PAK" ]; then
  if [ -f "$controlfolder/utils/patcher.txt" ]; then
    $ESUDO chmod a+x "$GAMEDIR/tools/patchscript"
    source "$controlfolder/utils/patcher.txt"
    $ESUDO kill -9 $(pidof gptokeyb)
  else
    pm_message "This port requires the latest version of PortMaster."
    exit 0
  fi
else
  pm_message "Extraction process already completed. Skipping."
fi

mkdir -p $CONFDIR/config
mkdir -p $CONFDIR/local

export XDG_CONFIG_HOME=$CONFDIR/config
export XDG_DATA_HOME=$CONFDIR/local

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH=$GAMEDATA/libs.aarch64:$LD_LIBRARY_PATH

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

# Calculate deadzone_scale based on DISPLAY_WIDTH
value=$((6*DISPLAY_WIDTH/480))
echo "Setting dpad_mouse_step and deadzone_scale to $value"
sed -i -E "s/(dpad_mouse_step|deadzone_scale) = .*/\1 = $value/g" \
  "$GAMEDIR"/$BINARY.ini*

$GPTOKEYB2 "$BINARY" -c "./$BINARY.ini" &

pm_platform_helper "$GAMEDIR/$BINARY"

./$BINARY --data-dir="$DATADIR" --data-dir="$GAMEDIR/data.libertatis"

pm_finish
