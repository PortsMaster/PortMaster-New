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

GAMEDIR=/$directory/ports/f1spirit
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" 
export TEXTINPUTINTERACTIVE="Y"

# Adjust screen size to maximum 4:3 dimensions that will fit
echo Screen size = ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}
if [ $((${DISPLAY_WIDTH} > ${DISPLAY_HEIGHT}*4/3)) != 0 ]; then
  echo Screen is wider than 4:3, so reducing width
  DISPLAY_WIDTH=$((${DISPLAY_HEIGHT}*4/3))
elif [ $((${DISPLAY_WIDTH} < ${DISPLAY_HEIGHT}*4/3)) != 0 ]; then
  echo Screen is taller than 4:3, so reducing height
  DISPLAY_HEIGHT=$((${DISPLAY_WIDTH}*3/4))
fi
echo Adjusted screen size = ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}

export DISPLAY_WIDTH
export DISPLAY_HEIGHT
export FULLSCREEN=false

# Uncomment these lines to set custom display parameters
#export DISPLAY_WIDTH=720
#export DISPLAY_HEIGHT=720
#export FULLSCREEN=true

$GPTOKEYB "f1spirit" -c "f1spirit.gptk" &

pm_platform_helper "$GAMEDIR/f1spirit"

./f1spirit

pm_finish

