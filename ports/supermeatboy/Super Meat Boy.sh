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
export PORT_32BIT="Y"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

BINARYNAME="SuperMeatBoy"
GAMEDIR=/$directory/ports/supermeatboy
CONFDIR="$GAMEDIR/conf/"

CUR_TTY=/dev/tty0
$ESUDO chmod 666 $CUR_TTY

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# extract Humble version if it's there
if [[ -f "${GAMEDIR}/gamedata/supermeatboy-linux-11112013-bin" ]]; then
  if [ "$CFW_NAME" == "muOS" ]; then
    # Busybox unzip doesnt like it, we use zip to fix it, but zip wants the file to be named .zip
    mv "${GAMEDIR}/gamedata/supermeatboy-linux-11112013-bin" "${GAMEDIR}/gamedata/supermeatboy-linux-11112013-broken.zip"
    zip -FF "${GAMEDIR}/gamedata/supermeatboy-linux-11112013-broken.zip" --out "${GAMEDIR}/gamedata/supermeatboy-linux-11112013-fixed.zip"
    mv "${GAMEDIR}/gamedata/supermeatboy-linux-11112013-fixed.zip" "${GAMEDIR}/gamedata/supermeatboy-linux-11112013-bin"
    rm -f "${GAMEDIR}/gamedata/supermeatboy-linux-11112013-broken.zip"
  fi

  echo "Extracting Humble version..."
  unzip "${GAMEDIR}/gamedata/supermeatboy-linux-11112013-bin" -x 'guis/*' 'meta/*' 'scripts/*' 'data/amd64/*' -d "${GAMEDIR}/gamedata/"
  mv ${GAMEDIR}/gamedata/data/* ${GAMEDIR}/gamedata
  # move the Humble archive to a subfolder so it only gets extracted on the first run
  mkdir -p ${GAMEDIR}/gamedata/humble
  mv "${GAMEDIR}/gamedata/supermeatboy-linux-11112013-bin" "${GAMEDIR}/gamedata/humble"
fi

cd $GAMEDIR

mkdir -p "$GAMEDIR/conf"

# Set the XDG environment variables for config & savefiles
export XDG_DATA_HOME="$CONFDIR"

# If there isn't a config file present, copy the default one to avoid volume sliders being set to zero
if [ ! -f "$GAMEDIR/conf/SuperMeatBoy/UserData/reg0.dat" ] && [ ! -f "$GAMEDIR/gamedata/userdata/reg0.dat" ]; then
  echo "Can't locate a configuration file. Importing a default."
  cp "$GAMEDIR/conf/SuperMeatBoy/UserData/reg0.default" "$GAMEDIR/conf/SuperMeatBoy/UserData/reg0.dat"
fi

# Setup gl4es

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

cd $GAMEDIR/gamedata/

# determine best output resolution based on device CPU or RAM
output_res=${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}
if [ "$DEVICE_CPU" == "RK3326" ]; then
  detail_level="ultralowdetail"
elif [ "$DEVICE_CPU" == "RK3566" ]; then
  detail_level="lowdetail"
elif [ "$DEVICE_RAM" -ge 4 ]; then
  detail_level="highdetail"
else
  detail_level="meddetail"
fi

# uncomment these to manually override output settings:
#output_res="320x240"
#detail_level="ultralowdetail"
echo "Setting game resolution to $output_res, detail level to $detail_level"

# uncomment this to select ingame language. Default is US English (en_US.UTF8) eg: Brazilian Portuguese (pt_BR.UTF8):
#export LANG=pt_BR.UTF8
echo "Game language is set to $LANG"

# Setup Box86
#export BOX86_ALLOWMISSINGLIBS=1
export BOX86_LOG=1
export BOX86_DLSYM_ERROR=1
export BOX86_SHOWSEGV=1
export BOX86_SHOWBT=1
export BOX86_DYNAREC=1

export LD_LIBRARY_PATH="$GAMEDIR/box86/native":"/usr/lib/arm-linux-gnueabihf/":"/usr/lib32":"$GAMEDIR/libs/":"$LD_LIBRARY_PATH"
export BOX86_LD_LIBRARY_PATH="$GAMEDIR/box86/x86":"$GAMEDIR/box86/native":"$GAMEDIR/libs/x86:$GAMEDIR/gamedata/x86"

if [ "$LIBGL_FB" != "" ]; then
export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es/libGL.so.1"
fi

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTINTERACTIVE="Y"

$GPTOKEYB "box86" xbox360 &
$GAMEDIR/box86/box86 ./x86/$BINARYNAME -$output_res -$detail_level -fullscreen

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0