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

[ -f "/etc/os-release" ] && source "/etc/os-release"
CUR_TTY=/dev/tty0
GAMEDIR=/$directory/ports/wakingmars
CONFDIR="$GAMEDIR/conf/"

exec > >(tee "$GAMEDIR/log.txt") 2>&1

get_controls

$ESUDO chmod 666 $CUR_TTY
$ESUDO chmod 666 /dev/uinput

if [ "$OS_NAME" == "JELOS" ]; then
  export SPA_PLUGIN_DIR="/usr/lib32/spa-0.2"
  export PIPEWIRE_MODULE_DIR="/usr/lib32/pipewire-0.3/"
fi

cd $GAMEDIR

# Ensure the conf directory exists
mkdir -p "$GAMEDIR/conf"

# Set the XDG environment variables for config & savefiles
export XDG_CONFIG_HOME="$CONFDIR"
export XDG_DATA_HOME="$CONFDIR"

# Setup GL4ES
export LIBGL_ES=2
export LIBGL_GL=21
export LIBGL_FB=4

# Setup Box86
export BOX86_LOG=1

export LD_LIBRARY_PATH="$GAMEDIR/box86/native":"/usr/lib/arm-linux-gnueabihf/":"/usr/lib32":"$GAMEDIR/libs/":"$LD_LIBRARY_PATH"
export BOX86_LD_LIBRARY_PATH="$GAMEDIR/box86/x86":"$GAMEDIR/box86/native":"$GAMEDIR/libs/x86":

export SDL_VIDEO_GL_DRIVER="$GAMEDIR/box86/native/libGL.so.1"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

#export TEXTINPUTINTERACTIVE="Y"

if [ "$ANALOG_STICKS" = "1" ] || [ "$ANALOG_STICKS" = "0" ]; then
    GPTK_FILE="wakingmars_1stick.gptk"
else
    GPTK_FILE="wakingmars.gptk"
fi

$GPTOKEYB "wakingmars" -c "./$GPTK_FILE" &
$GAMEDIR/box86/box86 gamedata/wakingmars

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0