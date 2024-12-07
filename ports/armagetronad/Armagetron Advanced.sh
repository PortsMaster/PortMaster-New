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

get_controls

GAMEDIR=/$directory/ports/armagetronad
CONFDIR="$GAMEDIR/conf/"


> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

mkdir -p "$GAMEDIR/conf"

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTINTERACTIVE="Y"
#export XDG_DATA_HOME="$CONFDIR"

$ESUDO rm -rf ~/.armagetronad
ln -sfv /$directory/ports/armagetronad/conf/.armagetronad ~/

cd $GAMEDIR

if [ -f "${controlfolder}/libgl_${CFWNAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

CONFIG_FILE="conf/.armagetronad/var/user.cfg"
# Replace the width and height settings with the values from the environment variables
sed -i "s/ARMAGETRON_LAST_SCREENMODE_H [0-9]*/ARMAGETRON_LAST_SCREENMODE_H $DISPLAY_HEIGHT/" "$CONFIG_FILE"
sed -i "s/ARMAGETRON_LAST_SCREENMODE_W [0-9]*/ARMAGETRON_LAST_SCREENMODE_W $DISPLAY_WIDTH/" "$CONFIG_FILE"

sed -i "s/ARMAGETRON_LAST_WINDOWSIZE_H [0-9]*/ARMAGETRON_LAST_WINDOWSIZE_H $DISPLAY_HEIGHT/" "$CONFIG_FILE"
sed -i "s/ARMAGETRON_LAST_WINDOWSIZE_W [0-9]*/ARMAGETRON_LAST_WINDOWSIZE_W $DISPLAY_WIDTH/" "$CONFIG_FILE"

sed -i "s/ARMAGETRON_SCREENMODE_H [0-9]*/ARMAGETRON_SCREENMODE_H $DISPLAY_HEIGHT/" "$CONFIG_FILE"
sed -i "s/ARMAGETRON_SCREENMODE_W [0-9]*/ARMAGETRON_SCREENMODE_W $DISPLAY_WIDTH/" "$CONFIG_FILE"

sed -i "s/ARMAGETRON_WINDOWSIZE_H [0-9]*/ARMAGETRON_WINDOWSIZE_H $DISPLAY_HEIGHT/" "$CONFIG_FILE"
sed -i "s/ARMAGETRON_WINDOWSIZE_W [0-9]*/ARMAGETRON_WINDOWSIZE_W $DISPLAY_WIDTH/" "$CONFIG_FILE"

$GPTOKEYB "armagetronad.${DEVICE_ARCH}" -c "./armagetronad.gptk" &
./armagetronad.${DEVICE_ARCH}

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0