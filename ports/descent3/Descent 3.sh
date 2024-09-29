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

# Variables - Set DEBUGMODE to 1 to use the Debug build
GAMEDIR="/$directory/ports/descent3"
DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
INIFILE="$GAMEDIR/d3.ini"
REGFILE="$GAMEDIR/config/.Descent3Registry"
DEBUGMODE=0


# Use positional parameters for key mapping
key_mapping_keys=""
key_mapping_values=""
key_types_keys=""
key_types_values=""

cd $GAMEDIR

# Setup permissions
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
$ESUDO chmod 777 "$GAMEDIR/game"
echo "Loading, please wait... (might take a while!)" > /dev/tty0

# Create config dir
rm -rf "$XDG_DATA_HOME/Outrage Entertainment/Descent 3"
ln -s "$GAMEDIR/config" "$XDG_DATA_HOME/Outrage Entertainment/Descent 3"

# Source to parse d3.ini and import its settings
source "$GAMEDIR/config/parseini.txt"

# Delete everything in the cache directory
rm -rf "$GAMEDIR/gamedata/custom/cache/"
mkdir "$GAMEDIR/gamedata/custom/cache/"

# Setup gl4es environment
if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [ "$LIBGL_FB" != "" ]; then
  export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es.aarch64/libGL.so.1"
  export LIBGL_DRIVERS_PATH="$GAMEDIR/gl4es.$DEVICE_ARCH/libGL.so.1"
  ARG="-g $LIBGL_DRIVERS_PATH"
fi 

export LD_LIBRARY_PATH="$GAMEDIR/libs.$DEVICE_ARCH:/usr/lib:$LD_LIBRARY_PATH"

# Run the game
$GPTOKEYB game -c "config/joy.gptk" & 
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
./game -setdir "$GAMEDIR/gamedata" -pilot Player -nooutragelogo -nomotionblur -logfile $ARG

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events & 
printf "\033c" >> /dev/tty1