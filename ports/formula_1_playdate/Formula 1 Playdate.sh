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

get_controls

GAMEDIR=/$directory/ports/formula_1_playdate

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

# You can either use XDG variables to redirect the Ports to our gamefolder if the port supports it:
CONFDIR="$GAMEDIR/conf/"

# Ensure the conf directory exists
mkdir -p "$GAMEDIR/conf"

# Set the XDG environment variables for config & savefiles
export XDG_CONFIG_HOME="$CONFDIR"
export XDG_DATA_HOME="$CONFDIR"

#for game save XDG_DATA_HOME had no effect
export HOME="$CONFDIR"

# Make sure uinput is accessible so we can make use of the gptokeyb controls.  351Elec/AmberElec, uOS and JelOS always runs in root, naughty naughty.  
# The other distros don't so the $ESUDO variable provides the sudo or not dependant on the OS this script is run from.
$ESUDO chmod 666 /dev/uinput

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

#required or select + start won't quit on arkos
if [[ "$CFW_NAME" == *"ArkOS"* ]]; then
   program="formula_1_playd"
else
   program="formula_1_playdate.${DEVICE_ARCH}"
fi

$GPTOKEYB "$program" -c "./formula_1_playdate.gptk" &
./formula_1_playdate.${DEVICE_ARCH}
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
