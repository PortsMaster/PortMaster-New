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

GAMEDIR=/$directory/ports/rlone/
CONFDIR="$GAMEDIR/conf/"

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

# Ensure the conf directory exists
mkdir -p "$GAMEDIR/conf"

# Set the XDG environment variables for config & savefiles
export XDG_CONFIG_HOME="$CONFDIR"
export XDG_DATA_HOME="$CONFDIR"

export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

CUR_TTY=/dev/tty0

# Update the configuration file with the display dimensions
sed -i "s/width\s*=\s*[0-9]*/width = $DISPLAY_WIDTH/" "$GAMEDIR/res/cfg/autorun.ini"
sed -i "s/height\s*=\s*[0-9]*/height = $DISPLAY_HEIGHT/" "$GAMEDIR/res/cfg/autorun.ini"

if [ $DISPLAY_WIDTH == '480' ]; then
      sed -i 's/font_scale[[:space:]]*=[[:space:]]*[^[:space:]]*/font_scale = 1.3/' "$GAMEDIR/res/cfg/autorun.ini"
elif [ $DISPLAY_WIDTH == '640' ] || [ $DISPLAY_WIDTH == '720' ]; then
      sed -i 's/font_scale[[:space:]]*=[[:space:]]*[^[:space:]]*/font_scale = 1.8/' "$GAMEDIR/res/cfg/autorun.ini"
elif [ $DISPLAY_WIDTH == '960' ] || [ $DISPLAY_WIDTH == '1280' ]; then
      sed -i 's/font_scale[[:space:]]*=[[:space:]]*[^[:space:]]*/font_scale = 2.2/' "$GAMEDIR/res/cfg/autorun.ini"
elif [[ $DISPLAY_WIDTH == '1920' ]]; then
      sed -i 's/font_scale[[:space:]]*=[[:space:]]*[^[:space:]]*/font_scale = 2.5/' "$GAMEDIR/res/cfg/autorun.ini"
else
      sed -i 's/font_scale[[:space:]]*=[[:space:]]*[^[:space:]]*/font_scale = 2.0/' "$GAMEDIR/res/cfg/autorun.ini"
fi

$GPTOKEYB "rlone" -c "./rlone.gptk" &
./rlone

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty0

