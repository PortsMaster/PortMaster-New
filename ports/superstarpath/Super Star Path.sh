#!/bin/bash
# PORTMASTER: superstarpath.zip, Super Star Path.sh
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

GAMEDIR=/$directory/ports/superstarpath

if [ "$OS_NAME" == "JELOS" ]; then
  export SPA_PLUGIN_DIR="/usr/lib32/spa-0.2"
  export PIPEWIRE_MODULE_DIR="/usr/lib32/pipewire-0.3/"
fi

# Port specific additional libraries should be included within the port's directory in a separate subfolder named libs.
# Prioritize the armhf libs to avoid conflicts with aarch64
export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$GAMEDIR/utils/libs"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"


# Patch game
cd "$GAMEDIR"
# If "gamedata/game.unx" exists and its size is 911,688 bytes, apply the xdelta3 patch
if [ -f "./gamedata/game.unx" ]; then
    file_size=$(ls -l "./gamedata/game.unx" | awk '{print $5}')
    if [ "$file_size" -eq 911688 ]; then
        $ESUDO ./patch/xdelta3 -d -s gamedata/game.unx -f ./patch/game.xdelta gamedata/game.unx
    fi
fi

# If "gamedata/audiogroup1.dat" exists and its size is 3,204,899 bytes, apply the xdelta3 patch
if [ -f "./gamedata/audiogroup1.dat" ]; then
    file_size=$(ls -l "./gamedata/audiogroup1.dat" | awk '{print $5}')
    if [ "$file_size" -eq 3204899 ]; then
        $ESUDO ./patch/xdelta3 -d -s gamedata/audiogroup1.dat -f ./patch/audio1.xdelta gamedata/audiogroup1.dat
    fi
fi

# If "gamedata/audiogroup2.dat" exists and its size is 9,763,779 bytes, apply the xdelta3 patch
if [ -f "./gamedata/audiogroup2.dat" ]; then
    file_size=$(ls -l "./gamedata/audiogroup2.dat" | awk '{print $5}')
    if [ "$file_size" -eq 9763779 ]; then
        $ESUDO ./patch/xdelta3 -d -s gamedata/audiogroup2.dat -f ./patch/audio2.xdelta gamedata/audiogroup2.dat
    fi
fi


# We log the execution of the script into log.txt
exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

# Check for file existence before trying to manipulate them:
[ -f "./gamedata/data.unx" ] && mv gamedata/data.unx gamedata/game.droid
[ -f "./gamedata/game.unx" ] && mv gamedata/game.unx gamedata/game.droid

# Make sure uinput is accessible so we can make use of the gptokeyb controls
$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "gmloader" -c ./superstarpath.gptk &

$ESUDO chmod +x "$GAMEDIR/gmloader"

./gmloader superstarpath.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
