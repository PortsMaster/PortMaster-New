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

GAMEDIR="/$directory/ports/doom3"

cd $GAMEDIR

$ESUDO rm -rf ~/.local/share/d3wasm
ln -sfv $GAMEDIR/conf/d3wasm/ ~/.local/share/

$ESUDO rm -rf ~/.config/d3wasm
ln -sfv $GAMEDIR/conf/d3wasm/ ~/.config/

whichos=$(grep "title=" "/usr/share/plymouth/themes/text.plymouth")
if [[ $whichos == *"RetroOZ"* ]]; then
  SDL2_LIB_PATH="/usr/lib/aarch64-linux-gnu"
  execute_perf=0
else
  SDL2_LIB_PATH="/usr/lib"
  execute_perf=1
fi
export LD_PRELOAD=$SDL2_LIB_PATH/libSDL2-2.0.so.0.16.0
export SDL_VIDEO_GL_DRIVER=./libs/libGL.so.1
export SDL_VIDEO_EGL_DRIVER=./libs/libEGL.so.1
export LIBGL_ES=2
export LIBGL_GL=21
export LIBGL_FB=4

source /etc/profile
((execute_perf)) && maxperf

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "d3wasm" -c "./d3wasm.gptk" &
LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH" SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./d3wasm 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof gptokeyb) 
((execute_perf)) && normperf
$ESUDO systemctl restart oga_events & 
unset LD_PRELOAD
printf "\033c" >> /dev/tty1
