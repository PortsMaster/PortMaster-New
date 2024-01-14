#!/bin/bash
if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt

get_controls

GAMEDIR=/$directory/ports/widelands/
CONFDIR="$GAMEDIR/conf/"

cd $GAMEDIR

# Ensure the conf directory exists
mkdir -p "$GAMEDIR/conf"

# Set the XDG environment variables for config & savefiles
export XDG_CONFIG_HOME="$CONFDIR"
export XDG_DATA_HOME="$CONFDIR"

export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTINTERACTIVE="Y"

#Set up GL4ES
export LIBGL_ES=2
export LIBGL_GL=21
export LIBGL_FB=4

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
 
./widelands --datadir=data --homedir=conf 2>&1 | tee $GAMEDIR/log.txt

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0