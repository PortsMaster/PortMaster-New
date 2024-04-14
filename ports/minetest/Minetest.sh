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
source $controlfolder/tasksetter

get_controls

CUR_TTY=/dev/tty0

PORTDIR="/$directory/ports/"
GAMEDIR="${PORTDIR}/minetest"
cd $GAMEDIR

# Grab text output...
$ESUDO chmod 666 $CUR_TTY
"$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
export TERM=linux
printf "\033c" > $CUR_TTY

# Remove libcurl.so.4 if it already exists in system libraries
FILE_TO_CHECK="libcurl.so.4" # Example library file name
EXTRA_LIB_FOLDER="libs.aarch64"
FILE_TO_DELETE="$GAMEDIR/$EXTRA_LIB_FOLDER/$FILE_TO_CHECK"

# Convert LD_LIBRARY_PATH into an array of directories
IFS=':' read -ra DIRS <<< "$LD_LIBRARY_PATH"

for dir in "${DIRS[@]}"; do  # Iterate over dirs in LD_LIBRARY_PATH
    full_path="$dir/$FILE_TO_CHECK"
    if [ -f "$full_path" ]; then  # If file exists locally...
        if [ -f "$FILE_TO_DELETE" ]; then  #...and it exists in bundle
            rm "$FILE_TO_DELETE"  # ...then delete it in bundle
        fi
        break
    fi
done

export LD_LIBRARY_PATH="$GAMEDIR/$EXTRA_LIB_FOLDER:$LD_LIBRARY_PATH"

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Load control config appropriate to available joysticks
if [ "$ANALOG_STICKS" = "0" ]; then
    GPTK_FILE="minetest_0stick.gptk"
    # Turn on autojump
    # if ! grep -Fxq "autojump" "$GAMEDIR/minetest.conf"; then
    #     echo 'autojump = true' | sudo tee -a "$GAMEDIR/minetest.conf"
    # fi
elif [ "$ANALOG_STICKS" = "1" ]; then
    GPTK_FILE="minetest_1stick.gptk"
    # Turn on autojump
    # if ! grep -Fxq "autojump" "$GAMEDIR/minetest.conf"; then
    #     echo 'autojump = true' | sudo tee -a "$GAMEDIR/minetest.conf"
    # fi
else
    GPTK_FILE="minetest_2stick.gptk"
fi

$GPTOKEYB "./bin/minetest" -c "$GAMEDIR/$GPTK_FILE" &
$TASKSET ./bin/minetest

$ESUDO kill -9 $(pidof gptokeyb)
unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
$ESUDO systemctl restart oga_events &

# Disable console
printf "\033c" >> $CUR_TTY
