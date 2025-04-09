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

# Variables
GAMEDIR=/$directory/ports/lugaruhd
CONFDIR="$GAMEDIR/conf/"
BINARY=lugaru
cd $GAMEDIR

# Enable logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Fix resolution presets
sed -i "/^Screenwidth:/ {n;s/.*/$DISPLAY_WIDTH/}" conf/config.txt
sed -i "/^Screenheight:/ {n;s/.*/$DISPLAY_HEIGHT/}" conf/config.txt

# Bind directories and XDG to portfolder
bind_directories ~/.config/$BINARY $GAMEDIR/conf
export XDG_DATA_HOME="$CONFDIR"

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Rendering fixes
if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [ "$LIBGL_FB" != "" ]; then
export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es.${DEVICE_ARCH}/libGL.so.1"
export SDL_VIDEO_EGL_DRIVER="$GAMEDIR/gl4es.${DEVICE_ARCH}/libEGL.so.1"
fi

# Run port
$GPTOKEYB "$BINARY.${DEVICE_ARCH}" -c "./$BINARY.gptk" &
pm_platform_helper "$GAMEDIR/$BINARY.${DEVICE_ARCH}"
./$BINARY.${DEVICE_ARCH}
pm_finish
