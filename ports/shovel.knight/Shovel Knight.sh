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
source $controlfolder/tasksetter
source $controlfolder/device_info.txt
export PORT_32BIT="Y"


[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
printf "\033c" > /dev/tty0
printf "\033c" > /dev/tty1

GAMEDIR="/$directory/ports/shovelknight"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"

# Fix for the annoying folder structure while still working with the previous
# one.
if [ -d "$GAMEDIR/gamedata/shovelknight/32" ]; then
	cd $GAMEDIR/gamedata/shovelknight/32
else
	cd $GAMEDIR/gamedata/32
fi

# Request libGL from Portmaster
if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [ "$LIBGL_ES" != "" ]; then
	export SDL_VIDEO_EGL_DRIVER="${GAMEDIR}/gl4es/libEGL.so.1"
	export SDL_VIDEO_GL_DRIVER="${GAMEDIR}/gl4es/libGL.so.1"
fi

# Force-enable SDL2 JGUID fix, see: https://github.com/ptitSeb/box86/commit/a0a33896519
export BOX86_SDL2_JGUID=1
export LIBGL_NOBANNER=1
export BOX86_LOG=0
export BOX86_LD_PRELOAD=$GAMEDIR/libShovelKnight.so
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$GAMEDIR/box86/native:/usr/lib:/usr/lib32
export BOX86_LD_LIBRARY_PATH=$GAMEDIR/box86/lib:/usr/lib32/:./:lib/:lib32/:x86/
export BOX86_DYNAREC=1
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO rm -rf ~/.local/share/Yacht\ Club\ Games
$ESUDO ln -s $GAMEDIR/Yacht\ Club\ Games ~/.local/share/
$ESUDO chmod 666 /dev/uinput

chmod +x ShovelKnight $GAMEDIR/box86/box86
$GPTOKEYB "ShovelKnight" -c "$GAMEDIR/shovelknight.gptk" &
echo "Loading, please wait... (might take a while!)" > /dev/tty0
$TASKSET $GAMEDIR/box86/box86 ShovelKnight

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
unset SDL_GAMECONTROLLERCONFIG
unset LD_LIBRARY_PATH
printf "\033c" >> /dev/tty1
printf "\033c" >> /dev/tty0
