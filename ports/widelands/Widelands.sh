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
export XDG_DATA_HOME="$CONFDIR"

export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTINTERACTIVE="Y"

# Define the archive file name
ARCHIVE_FILE="data.tar.gz"

# Check if the archive file exists
if [[ -f "$ARCHIVE_FILE" ]]; then
   # Remove the old data directory if it exists
   if [[ -d 'data/' ]]; then
     pm_message "Removing old game data"
     $ESUDO rm -fR 'data/'
   fi
   pm_message "Extracting game data, this can take a few minutes..."
   
   # Extract the archive and check if the extraction was successful
   if [ "$CFW_NAME" = "muOS" ]; then
       if gunzip -c "$ARCHIVE_FILE" | tar xf -; then
           pm_message "Extraction successful."
           $ESUDO rm -f "$ARCHIVE_FILE"
       else
           pm_message "Error: Extraction failed."
           sleep 5
           exit 1
       fi
   else
       if tar -xzf "$ARCHIVE_FILE"; then
           pm_message "Extraction successful."
           $ESUDO rm -f "$ARCHIVE_FILE"
       else
           pm_message "Error: Extraction failed."
           sleep 5
           exit 1
       fi
   fi
elif [ ! -d 'data/' ]; then
   pm_message "Error: No data directory present and Archive file $ARCHIVE_FILE not found."
   sleep 5
   exit 1  # Exit the script if no data directory and no archive file
fi

$GPTOKEYB "widelands" -c "./widelands.gptk" &
 
pm_platform_helper "$GAMEDIR/widelands" 
./widelands --datadir=data --homedir=conf

pm_finish