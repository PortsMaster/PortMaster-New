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

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR=/$directory/ports/openenroth
CONFDIR="$GAMEDIR/conf/"
BINARY=OpenEnroth

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

mkdir -p "$GAMEDIR/conf"
bind_directories ~/.openenroth $GAMEDIR/conf

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

cd $GAMEDIR

export PATCHER_FILE="$GAMEDIR/tools/patchscript"
export PATCHER_TIME="2 minutes"

if [ ! -d "$GAMEDIR/gamedata/DATA" ] && [ ! -d "$GAMEDIR/gamedata/data" ]; then
  if [ -f "$controlfolder/utils/patcher.txt" ]; then
    $ESUDO chmod a+x "$GAMEDIR/tools/patchscript"
    source "$controlfolder/utils/patcher.txt"
    $ESUDO kill -9 $(pidof gptokeyb)
  else
    echo "This port requires the latest version of PortMaster." > $CUR_TTY
  fi
else
  echo "Extraction process already completed. Skipping."
fi

if [[ "${CFW_NAME}" == ROCKNIX ]]; then
  # export for Panfrost compatibility (safe on all platforms)
  export MESA_GLES_VERSION_OVERRIDE=3.2
  echo Using standard cursor
  export USE_GL_CURSOR=false
else
  # most CFWs will need the GL cursor
  echo Using GL cursor
  export USE_GL_CURSOR=true
fi

# Calculate dpad_mouse_step and deadzone_scale based on DISPLAY_WIDTH
value=$((4*DISPLAY_WIDTH/480))
echo "Setting dpad_mouse_step and deadzone_scale to $value"
sed -i -E "s/(dpad_mouse_step|deadzone_scale) = .*/\1 = $value/g" \
  "$GAMEDIR"/$BINARY.gptk*

$GPTOKEYB "$BINARY" -c ./$BINARY.gptk &
pm_platform_helper "$GAMEDIR/$BINARY"

./$BINARY --data-path gamedata/

pm_finish
