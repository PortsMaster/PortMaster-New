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
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

# uncomment and modify the following line to select a custom ingame language (this example changes it from the OS default US English (en_US.UTF8) to Brazilian Portuguese (pt_BR.UTF8))
#export LANG=pt_BR.UTF8

BINARYNAME="SuperMeatBoy"
GAMEDIR=/$directory/ports/supermeatboy
CONFDIR="$GAMEDIR/conf/"

CUR_TTY=/dev/tty0
$ESUDO chmod 666 $CUR_TTY

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR/gamedata/

mkdir -p "$GAMEDIR/conf"

# Set the XDG environment variables for config & savefiles
export XDG_DATA_HOME="$CONFDIR"

# Setup gl4es
if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

# Setup Box86
#export BOX86_ALLOWMISSINGLIBS=1
export BOX86_LOG=1
export BOX86_DLSYM_ERROR=1
export BOX86_SHOWSEGV=1
export BOX86_SHOWBT=1
export BOX86_DYNAREC=1

export LD_LIBRARY_PATH="$GAMEDIR/box86/native":"/usr/lib/arm-linux-gnueabihf/":"/usr/lib32":"$GAMEDIR/libs/":"$LD_LIBRARY_PATH"
export BOX86_LD_LIBRARY_PATH="$GAMEDIR/box86/x86":"$GAMEDIR/box86/native":"$GAMEDIR/libs/x86:$GAMEDIR/gamedata/x86"

export SDL_VIDEO_GL_DRIVER="$GAMEDIR/box86/native/libGL.so.1"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

export TEXTINPUTINTERACTIVE="Y"

pwd
$GPTOKEYB "box86" xbox360 &
# edit resolution parameter to suit device. add -lowdetail or -ultralowdetail to help performance in boss levels
$GAMEDIR/box86/box86 ./x86/$BINARYNAME -640x480 -fullscreen

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
