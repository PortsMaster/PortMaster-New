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

GAMEDIR="/$directory/ports/hexen2"

cd $GAMEDIR

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [ "$LIBGL_FB" != "" ] && [ "${CFW_NAME^^}" != "KNULLI" ]; then
  export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es.aarch64/libGL.so.1"
  export SDL_VIDEO_EGL_DRIVER="$GAMEDIR/gl4es.aarch64/libEGL.so.1"
fi 

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

bind_directories ~/.hexen2 $GAMEDIR/conf/.hexen2
$ESUDO cp -f "$GAMEDIR/conf/.hexen2/portals/config.cfg" "$GAMEDIR/portals/autoexec.cfg"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO chmod +x "$GAMEDIR/glhexen2.${DEVICE_ARCH}"

if [[ "${DEVICE_NAME^^}" == "X55" ]] || [[ "${DEVICE_NAME^^}" == "RG353P" ]] || [[ "${DEVICE_NAME^^}" == "RG40XX-H" ]] || [[ "${CFW_NAME^^}" == "RETRODECK" ]]; then
    GPTOKEYB_CONFIG="$GAMEDIR/hexen2triggers.gptk"  
else
    GPTOKEYB_CONFIG="$GAMEDIR/hexen2.gptk"
fi

ADDLPARAMS="-conwidth 340 -lm_2 +viewsize 120 +gl_glows 1 +gl_extra_dynamic_lights 1 +gl_missile_glows 1 +gl_other_glows 1 +gl_colored_dynamic_lights 1 +gl_coloredlight 2 +r_waterwarp 0 +showfps 0"

# Load directly into an expansion, a map, or a mod
RUNMOD="-portals"

$GPTOKEYB "glhexen2.${DEVICE_ARCH}" -c "$GPTOKEYB_CONFIG" &
pm_platform_helper "$GAMEDIR/glhexen2.${DEVICE_ARCH}"
./glhexen2.${DEVICE_ARCH} -width $DISPLAY_WIDTH -height $DISPLAY_HEIGHT $ADDLPARAMS -basedir ./ $RUNMOD

pm_finish
