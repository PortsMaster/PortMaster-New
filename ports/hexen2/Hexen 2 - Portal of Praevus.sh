#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/device_info.txt

get_controls

[ -f "/etc/os-release" ] && source "/etc/os-release"

GAMEDIR="/$directory/ports/hexen2"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO chmod 777 -R $GAMEDIR/*

if [ "$DEVICE_NAME" == "x55" ] || [ "$DEVICE_NAME" == "RG353P" ]; then
    GPTOKEYB_CONFIG="$GAMEDIR/hexen2triggers.gptk"  
else
    GPTOKEYB_CONFIG="$GAMEDIR/hexen2.gptk"
fi

ADDLPARAMS="-conwidth 340 -lm_2 +viewsize 120 +gl_glows 1 +gl_extra_dynamic_lights 1 +gl_missile_glows 1 +gl_other_glows 1 +gl_colored_dynamic_lights 1 +gl_coloredlight 2 +r_waterwarp 0 +showfps 0"

# Load directly into an expansion, a map, or a mod
RUNMOD="-portals"

cd $GAMEDIR

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1

# gl4es
export LIBGL_GL=15
export LIBGL_ES=1

# Detect JelOS/Device combination and address GL libs accordingly.
if [ "$OS_NAME" == "JELOS" ] && [ "$DEVICE_NAME" == "RG351P" ] || [ "$DEVICE_NAME" == "RG351M" ] || [ "$DEVICE_NAME" == "RG351MP" ] || [ "$DEVICE_NAME" == "RG351V" ]; then
  [ -f "$GAMEDIR/libs.jelos/libEGL.so.1" ] && $ESUDO rm -rf "$GAMEDIR/libs.jelos/libEGL.so.1"
else
  [ ! -f "$GAMEDIR/libs.jelos/libEGL.so.1" ] && $ESUDO cp -f "$GAMEDIR/lib/libEGL.so.1" "$GAMEDIR/libs.jelos/libEGL.so.1"
fi

if [ "$OS_NAME" == "JELOS" ]; then
  export LD_LIBRARY_PATH="$GAMEDIR/libs.jelos:/usr/lib:$LD_LIBRARY_PATH"
else
  export LD_LIBRARY_PATH="$GAMEDIR/lib:$LD_LIBRARY_PATH"
fi

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# setup symbolic link to config directory
$ESUDO rm -rf ~/.hexen2
$ESUDO ln -sfv $GAMEDIR/conf/.hexen2 ~/

$GPTOKEYB "glhexen2" -c "$GPTOKEYB_CONFIG" &
./glhexen2 -width $DISPLAY_WIDTH -height $DISPLAY_HEIGHT $ADDLPARAMS -basedir ./ $RUNMOD

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty1
