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
source $controlfolder/device_info.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

BINARYNAME="Barbarian"
GAMEDIR=/$directory/ports/barbarian
CONFDIR="$GAMEDIR/conf/"

CUR_TTY=/dev/tty0
$ESUDO chmod 666 $CUR_TTY

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

mkdir -p "$GAMEDIR/conf"

# Set the XDG environment variables for config & savefiles
export XDG_DATA_HOME="$CONFDIR"

# Setup gl4es
if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

cd $GAMEDIR/gamedata/

# mkdir -p "$GAMEDIR/conf"
# $ESUDO rm -rf ~/.folder
# ln -sfv $GAMEDIR/conf/ ~/.folder

# Setup Box86
#export BOX86_ALLOWMISSINGLIBS=1
export BOX86_LOG=1
export BOX86_DLSYM_ERROR=1
export BOX86_SHOWSEGV=1
export BOX86_SHOWBT=1

export LD_LIBRARY_PATH="$GAMEDIR/box86/native":"/usr/lib/arm-linux-gnueabihf/":"/usr/lib32":"$GAMEDIR/libs/":"$LD_LIBRARY_PATH"
export BOX86_LD_LIBRARY_PATH="$GAMEDIR/box86/x86":"$GAMEDIR/box86/native":"$GAMEDIR/libs/x86"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

if [ "$LIBGL_FB" != "" ]; then
export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es.armhf/libGL.so.1"
fi 

#export TEXTINPUTINTERACTIVE="Y"
echo $GPTOKEYB
echo $PWD
$GPTOKEYB "box86" -c "$GAMEDIR/barbarian.gptk" &
$GAMEDIR/box86/box86 "./$BINARYNAME"

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0