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

GAMEDIR=/$directory/ports/wesnoth
CONFDIR="$GAMEDIR/conf/"
BINARY=wesnoth

USERCONFIG_DIR="$GAMEDIR/conf/config"
mkdir -p "$USERCONFIG_DIR"
USERDATA_DIR="$GAMEDIR/conf/data"
mkdir -p "$USERDATA_DIR"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export PATCHER_FILE="$GAMEDIR/tools/patchscript"
export PATCHER_TIME="2-10 minutes"

if [ ! -d "$GAMEDIR/gamedata" ]; then
  if [ -f "$controlfolder/utils/patcher.txt" ]; then
    $ESUDO chmod a+x "$GAMEDIR/tools/patchscript"
    source "$controlfolder/utils/patcher.txt"
    $ESUDO kill -9 $(pidof gptokeyb)
  else
    echo "This port requires the latest version of PortMaster." > $CUR_TTY
  fi
fi

export LD_LIBRARY_PATH="$GAMEDIR/libs.aarch64:$LD_LIBRARY_PATH"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [[ ${CFW_NAME} == ROCKNIX ]]; then
  # sim-cursor not needed on rocknix
  BINARYPATH="$GAMEDIR/vanilla/wesnoth"

  # disable cursor auto-hide if on rocknix
  swaymsg 'seat * hide_cursor 0'

else
  # sim-cursor usually needed on other platforms
  BINARYPATH="$GAMEDIR/sim-cursor/wesnoth"
fi

# Calculate deadzone_scale based on DISPLAY_WIDTH
value=$((4*DISPLAY_WIDTH/480))
echo "Setting dpad_mouse_step and deadzone_scale to $value"
sed -i -E "s/(dpad_mouse_step|deadzone_scale) = .*/\1 = $value/g" \
  "$GAMEDIR"/$BINARY.ini*

export TEXTINPUTINTERACTIVE="Y"
$GPTOKEYB2 "$BINARY" -c "$BINARY.ini.$ANALOG_STICKS" >/dev/null &

pm_platform_helper "$BINARYPATH"

USER=$HOSTNAME $BINARYPATH \
  --userconfig-dir "$USERCONFIG_DIR" \
  --userdata-dir "$USERDATA_DIR" \
  ./gamedata

# put cursor auto-hide back on rocknix
if [[ ${CFW_NAME} == ROCKNIX ]]; then
  swaymsg "$(swaymsg -t get_config -p | grep hide_cursor)"
fi

pm_finish
