#!/bin/bash
# PORTMASTER: supermeatboy.zip, Super Meat Boy.sh
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

BINARY_NAME="SuperMeatBoy"
GAMEDIR=/$directory/ports/supermeatboy
CONFDIR="$GAMEDIR/UserData/"

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

# Ensure the userdata directory exists
mkdir -p "$GAMEDIR/UserData"

# Set the XDG environment variables for config & savefiles
export XDG_CONFIG_HOME="$CONFDIR"
export XDG_DATA_HOME="$CONFDIR"

# Setup gl4es
if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

export BOX86_DYNAREC=1
#export BOX86_FORCE_ES=31
export LIBGL_GL=21

# Setup Box86 logging
export BOX86_LOG=1
export BOX86_SHOWSEGV=1

export LD_LIBRARY_PATH="$GAMEDIR/box86/native":"/usr/lib/arm-linux-gnueabihf/":"/usr/lib32":"$GAMEDIR/libs/":"$LD_LIBRARY_PATH"
export BOX86_LD_LIBRARY_PATH="$GAMEDIR/box86/x86":"$GAMEDIR/box86/native":"$GAMEDIR/libs/x86":"$GAMEDIR/libs"

export SDL_VIDEO_GL_DRIVER="$GAMEDIR/box86/native/libGL.so.1"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

export TEXTINPUTINTERACTIVE="Y"

$GPTOKEYB "$BINARY_NAME" xbox360 &
$GAMEDIR/box86/box86 $GAMEDIR/x86/$BINARY_NAME -640x480 -fullscreen 2>&1 | tee $GAMEDIR/log.txt

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
