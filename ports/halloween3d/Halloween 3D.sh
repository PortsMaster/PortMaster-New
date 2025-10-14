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

GAMEDIR="/$directory/ports/halloween3d"

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

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO cp "$GAMEDIR/halloween.${DEVICE_ARCH}" "$GAMEDIR/halloween"

$ESUDO chmod +x "$GAMEDIR/halloween"
$ESUDO chmod +x "$GAMEDIR/7zzs.${DEVICE_ARCH}"

# Extract game files on 1st run
if [ ! -d "$GAMEDIR/system/textures" ]; then
    "$GAMEDIR/7zzs.${DEVICE_ARCH}" x "$GAMEDIR/system/gamedata.7z" -o"$GAMEDIR/system/"
    sleep 1
    rm -f "$GAMEDIR/gamedata.7z"
fi

case "${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}" in
    480x320)   MODE=1  ;;
    640x480)   MODE=4  ;;
    720x480)   MODE=5  ;;
    720x720)   MODE=6  ;;
    800x600)   MODE=7  ;;
    854x480)   MODE=8  ;;
    960x544)   MODE=9  ;;
    1024x768)  MODE=10 ;;
    1280x720)  MODE=12 ;;
    1280x800)  MODE=13 ;;
    1280x960)  MODE=14 ;;
    1680x1050) MODE=17 ;;
    1920x1080) MODE=18 ;;
    1920x1152) MODE=19 ;;
            *) MODE=4  ;; # 640x480 fallback
esac

sed -i "s/^videomode 4.*/videomode 4 ${MODE}.000000/" "$GAMEDIR/system/hconfig.cfg"

if [[ "${DEVICE_NAME^^}" == "X55" ]] || [[ "${DEVICE_NAME^^}" == "RG353P" ]] || [[ "${DEVICE_NAME^^}" == "RG40XX-H" ]] || [[ "${CFW_NAME^^}" == "RETRODECK" ]]; then
    GPTOKEYB_CONFIG="$GAMEDIR/halloween3dtriggers.gptk"  
else
    GPTOKEYB_CONFIG="$GAMEDIR/halloween3d.gptk"
fi

$GPTOKEYB "halloween" -c "$GPTOKEYB_CONFIG" &
pm_platform_helper "$GAMEDIR/halloween"
./halloween

pm_finish
