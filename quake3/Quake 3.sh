#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt

get_controls

GAMEDIR="/$directory/ports/quake3"

cd $GAMEDIR

$ESUDO rm -rf ~/.q3a
ln -sfv $GAMEDIR/conf/.q3a ~/

export SDL_VIDEO_GL_DRIVER="$GAMEDIR/libs/libGL.so.1"
export SDL_VIDEO_EGL_DRIVER="$GAMEDIR/libs/libEGL.so.1"
export LIBGL_ES=2
export LIBGL_GL=21
export LIBGL_FB=4

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "quake3e.aarch64" -c "$GAMEDIR/quake3e.aarch64.gptk" &
LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH" SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./quake3e.aarch64 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events & 
printf "\033c" >> /dev/tty1