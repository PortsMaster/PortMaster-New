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

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

GAMEDIR=/$directory/ports/widelands/
CONFDIR="$GAMEDIR/conf/"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Ensure the conf directory exists
mkdir -p "$GAMEDIR/conf"

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

# Set the XDG environment variables for config & savefiles
export XDG_CONFIG_HOME="$CONFDIR"
export XDG_DATA_HOME="$CONFDIR"

export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTINTERACTIVE="Y"

CUR_TTY=/dev/tty0

# Define the archive file name
ARCHIVE_FILE="data.tar.gz"

# Check if the archive file exists
if [[ -f "$ARCHIVE_FILE" ]]; then
   # Remove the old data directory if it exists
   if [[ -d 'data/' ]]; then
     echo "Removing old game data" > "$CUR_TTY"
     $ESUDO rm -fR 'data/'
   fi

   echo "Extracting game data, this can take a few minutes..." > "$CUR_TTY"
   
   # Extract the archive and check if the extraction was successful
   if tar -xzf "$ARCHIVE_FILE"; then
       echo "Extraction successful." > "$CUR_TTY"
       $ESUDO rm -f "$ARCHIVE_FILE"
   else
       echo "Error: Extraction failed." > "$CUR_TTY"
	   sleep 5
       exit 1
   fi
elif [ ! -d 'data/' ]; then
   echo "Error: No data directory present and Archive file $ARCHIVE_FILE not found." > "$CUR_TTY"
   exit 1  # Exit the script if no data directory and no archive file
fi

$GPTOKEYB "widelands" -c "./widelands.gptk" &
 
./widelands --datadir=data --homedir=conf

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
