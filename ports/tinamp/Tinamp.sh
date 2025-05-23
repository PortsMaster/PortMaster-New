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

#export PORT_32BIT="Y" # If using a 32 bit port
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR=/$directory/ports/tinamp/
CONFDIR="$GAMEDIR/conf/"

mkdir -p "$GAMEDIR/conf"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export XDG_DATA_HOME="$CONFDIR"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
#export TEXTINPUTINTERACTIVE="Y"

pm_platform_helper "$GAMEDIR/tinamp_aarch64"

export VLC_PLUGIN_PATH=$GAMEDIR/libs/vlc
./tinamp_aarch64
ret=$?
if [ "$ret" == "2" ]; then
    systemctl poweroff > /dev/null 2>&1
    ret=$?
    if [ "$ret" != "0" ]; then
      echo "Trying muos alternative to systemctl poweroff"
      /opt/muos/bin/shutdown -P > /dev/null 2>&1
      ret=$?
      if [ "$ret" != "0" ]; then
        echo "Trying last resort plain poweroff"
        poweroff
      fi
    fi
fi

pm_finish
