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

GAMEDIR="/$directory/ports/nicechess"

cd $GAMEDIR

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [ "$LIBGL_FB" != "" ] && [ "${CFW_NAME^^}" != "KNULLI" ]; then
  export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es.${DEVICE_ARCH}/libGL.so.1"
  export SDL_VIDEO_EGL_DRIVER="$GAMEDIR/gl4es.${DEVICE_ARCH}/libEGL.so.1"
fi

[ "$DEVICE_CPU" == "RK3326" ] && export LIBGL_ES=1

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO cp "$GAMEDIR/nicechess.${DEVICE_ARCH}" "$GAMEDIR/nicechess"

$ESUDO chmod +x "$GAMEDIR/nicechess"

# Choose settings (for better speed on low powered devices)
if [[ "$DEVICE_CPU" == "SD865" ]] || [[ "${CFW_NAME^^}" == "RETRODECK" ]]; then
  ADDLPARAMS=" -hs -hp -r -s -ma -f"
elif [[ "$DEVICE_CPU" == "RK3566" ]] || [[ "$DEVICE_CPU" == "RK3399" ]] || [[ "$DEVICE_CPU" == "A55" ]] || [[ "${DEVICE_CPU^^}" == "H700" ]]; then
  ADDLPARAMS=" -hs -hp -s -ma"
else
  ADDLPARAMS=" -hs -hp -ma"
fi

if [[ "${DEVICE_NAME^^}" == "X55" ]] || [[ "${DEVICE_NAME^^}" == "RG353P" ]] || [[ "${DEVICE_NAME^^}" == "RG40XX-H" ]] || [[ "${CFW_NAME^^}" == "RETRODECK" ]]; then
    GPTOKEYB_CONFIG="$GAMEDIR/nicechesstriggers.gptk"  
elif [[ "${ANALOG_STICKS}" -lt 2 ]]; then
    GPTOKEYB_CONFIG="$GAMEDIR/nicechessnosticks.gptk"  
else
    GPTOKEYB_CONFIG="$GAMEDIR/nicechess.gptk"
fi

$GPTOKEYB "nicechess" -c "$GPTOKEYB_CONFIG" &
pm_platform_helper "$GAMEDIR/nicechess"
./nicechess $ADDLPARAMS -fn "$GAMEDIR/fonts/LiberationSans-Bold.ttf"

pm_finish
