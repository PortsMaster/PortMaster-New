#!/bin/bash
# Below we assign the source of the control folder (which is the PortMaster folder) based on the distro:
if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

# We source the control.txt file contents here
# The $ESUDO, $directory, $param_device and necessary 
# Sdl configuration controller configurations will be sourced from the control.txt
source $controlfolder/control.txt

# We pull the controller configs from the get_controls function from the control.txt file here
get_controls

$ESUDO chmod 666 /dev/tty0

# We check on emuelec based CFWs the OS_NAME 
[ -f "/etc/os-release" ] && source "/etc/os-release"

if [ "$OS_NAME" == "JELOS" ]; then
  export SPA_PLUGIN_DIR="/usr/lib32/spa-0.2"
  export PIPEWIRE_MODULE_DIR="/usr/lib32/pipewire-0.3/"
fi

GAMEDIR=/$directory/ports/blastius

# We log the execution of the script into log.txt
exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Port specific additional libraries should be included within the port's directory in a separate subfolder named libs.
# Prioritize the armhf libs to avoid conflicts with aarch64
export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$GAMEDIR/utils/libs"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"

cd $GAMEDIR

# If "gamedata/data.win" exists and its size is 3,389,976 bytes, apply the xdelta3 patch
if [ -f "./gamedata/data.win" ]; then
    file_size=$(ls -l "./gamedata/data.win" | awk '{print $5}')
    if [ "$file_size" -eq 3389976 ]; then
        $ESUDO $controlfolder/xdelta3 -d -s gamedata/data.win -f ./patch.xdelta gamedata/data.win
    fi
fi

# Check for file existence before trying to manipulate them:
[ -f "./gamedata/data.win" ] && mv gamedata/data.win gamedata/game.droid
[ -f "./gamedata/game.win" ] && mv gamedata/game.win gamedata/game.droid

# Make sure uinput is accessible so we can make use of the gptokeyb controls
$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "gmloader" -c ./blastius.gptk &

$ESUDO chmod +x "$GAMEDIR/gmloader"

./gmloader blastius.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
