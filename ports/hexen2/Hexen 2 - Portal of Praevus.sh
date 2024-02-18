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

GAMEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/hexen2"

if [ $DEVICE_NAME == 'x55' ] || [ $DEVICE_NAME == 'RG353P' ]; then
    GPTOKEYB_CONFIG="$GAMEDIR/hexen2triggers.gptk"  
else
    GPTOKEYB_CONFIG="$GAMEDIR/hexen2.gptk"
fi

$ESUDO chmod 777 -R $GAMEDIR/*

ADDLPARAMS="-conwidth 340 -lm_2 +viewsize 120 +gl_glows 1 +gl_extra_dynamic_lights 1 +gl_missile_glows 1 +gl_other_glows 1 +gl_colored_dynamic_lights 1 +gl_coloredlight 2 +r_waterwarp 0 +showfps 0"

# Load directly into an expansion, a map, or a mod
RUNMOD="-portals"

cd $GAMEDIR

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

# System (Also prepare runtime directories for User and Pulse Audio)
export LD_LIBRARY_PATH=$GAMEDIR/lib:$LD_LIBRARY_PATH
[ -f "$GAMEDIR/lib/libasound.so.2" ] && $ESUDO rm -f $GAMEDIR/lib/libasound.so.2 $GAMEDIR/lib/libvorbis.so.0 $GAMEDIR/lib/libvorbisenc.so.2 $GAMEDIR/lib/libvorbisfile.so.3
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# gl4es
export LIBGL_GL=15
export LIBGL_ES=1

# prep for clean log
$ESUDO rm $GAMEDIR/log.txt

# setup symbolic link to config directory
$ESUDO rm -rf ~/.hexen2
$ESUDO ln -s /$GAMEDIR/conf/.hexen2 ~/

$GPTOKEYB "glhexen2" -c "$GPTOKEYB_CONFIG" &
./glhexen2 -width $DISPLAY_WIDTH -height $DISPLAY_HEIGHT $ADDLPARAMS -basedir ./ $RUNMOD 2>&1 | tee -a ./log.txt

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty1
