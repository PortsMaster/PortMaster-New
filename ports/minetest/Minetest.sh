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

GAMEDIR="/$directory/ports/minetest"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

export TERM=linux
printf "\033c" > /dev/tty0

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

[ "$CFW_NAME" = "AmberELEC" -o "$CFW_NAME" = "muOS" ] && rm -f "$GAMEDIR/libs.$DEVICE_ARCH/libcurl.so.4"
CUR_TTY=/dev/tty0

# Define the archive file name
ARCHIVE_FILE="data.tar.gz"

# Check if the archive file exists
if [[ -f "$ARCHIVE_FILE" ]]; then
   echo "Extracting game data, this can take a few minutes..." > "$CUR_TTY"
   
   # Extract the archive and check if the extraction was successful
   if zcat "$ARCHIVE_FILE" | tar -xv; then
       echo "Extraction successful." > "$CUR_TTY"
       $ESUDO rm -f "$ARCHIVE_FILE"
   else
       echo "Error: Extraction failed." > "$CUR_TTY"
	   sleep 5
       exit 1
   fi
fi

[ "$CFW_NAME" = "AmberELEC" -o "$CFW_NAME" = "muOS" ] && [ -f "$GAMEDIR/libs.$DEVICE_ARCH/libcurl.so.4" ] && rm -f "$GAMEDIR/libs.$DEVICE_ARCH/libcurl.so.4"
ifconfig lo up
chmod +x ./bin/minetest
$GPTOKEYB "minetest" -c "$GAMEDIR/minetest.gptk.$ANALOG_STICKS" &
./bin/minetest

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty0
