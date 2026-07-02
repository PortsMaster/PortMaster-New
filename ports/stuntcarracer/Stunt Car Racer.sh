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

GAMEBINARY=stuntcarracer
GAMEDIR="/$directory/ports/stuntcarracer"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [ $DISPLAY_WIDTH -eq 720 ] && [ $DISPLAY_HEIGHT -eq 480 ]; then
 DISPLAY_RATIO="-s 0.90"
elif [ $DISPLAY_WIDTH -eq 720 ] && [ $DISPLAY_HEIGHT -eq 720 ]; then
 DISPLAY_RATIO="-s 1.12"
elif [ $DISPLAY_WIDTH -eq 480 ] && [ $DISPLAY_HEIGHT -eq 320 ]; then
 DISPLAY_RATIO="-s 0.75"
else
 DISPLAY_RATIO=""
fi

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$GPTOKEYB "$GAMEBINARY.${DEVICE_ARCH}" -c "./$GAMEBINARY.gptk" &
pm_platform_helper "$GAMEDIR/$GAMEBINARY.${DEVICE_ARCH}"
./$GAMEBINARY.${DEVICE_ARCH} -w $DISPLAY_WIDTH -h $DISPLAY_HEIGHT $DISPLAY_RATIO

pm_finish
