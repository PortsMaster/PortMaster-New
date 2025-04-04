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

GAMEDIR="/$directory/ports/freedroid"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Fix mouse resetting on ROCKNIX
if [[ "${CFW_NAME^^}" == 'ROCKNIX' ]] || [[ "${CFW_NAME^^}" == 'JELOS' ]]; then
    sed -i 's/^seat \* hide_cursor.*/seat * hide_cursor 300000/' ~/.config/sway/config
    swaymsg reload
    sleep 1
fi

if [[ "${DISPLAY_WIDTH}" -gt 1200 ]]; then
  fdrpgres=1280x720
else
  fdrpgres=640x480
fi

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [ "$LIBGL_FB" != "" ]; then
  export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es.${DEVICE_ARCH}/libGL.so.1"
  export SDL_VIDEO_EGL_DRIVER="$GAMEDIR/gl4es.${DEVICE_ARCH}/libEGL.so.1"
fi 

bind_directories ~/.freedroid_rpg "$GAMEDIR/conf/.freedroid_rpg"

$GPTOKEYB "freedroidRPG" -c "./freedroid.gptk" &
pm_platform_helper "$GAMEDIR/freedroidRPG.${DEVICE_ARCH}"
./freedroidRPG.${DEVICE_ARCH} -n -r $fdrpgres

pm_finish