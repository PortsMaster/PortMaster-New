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

# Setup permissions
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

# Variables
GAMEDIR="/$directory/ports/ziiaol"

# Exports
export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs32:$GAMEDIR/utils/libs":$LD_LIBRARY_PATH
export PORT_32BIT="Y"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_linux"

# Set current virtual screen
if [ "$CFW_NAME" == "muOS" ]; then
    /opt/muos/extra/muxlog & CUR_TTY="/tmp/muxlog_info"
else
    CUR_TTY="/dev/tty0"
fi

# Functions
install() {
    # Extract all files
    mkdir -p "$GAMEDIR/gamedata"
    echo "Extracting files.." > $CUR_TTY
    unzip "$FILE" -d "$GAMEDIR/gamedata"
    # Delete the stuff we don't need
    cd "$GAMEDIR/gamedata"
    rm -rf "\$TEMP" "\$PLUGINSDIR" *.exe *.txt *.dll *.ini
    # Rename stuff
    mv data.win "game.droid"
    # Clean up
    cd $GAMEDIR
    rm -rf $FILE
    touch installed
}

cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Check if installation needed
if [ ! -f "installed" ]; then
    FILE="Z2TAOL_P03.zip"
    echo "Performing first time setup, please wait.." > $CUR_TTY
    install
fi

echo "Loading, please wait..." > $CUR_TTY

$GPTOKEYB "gmloader" -c "zelda.gptk" &
$ESUDO chmod +xwr "$GAMEDIR/gmloader"
./gmloader game.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1
printf "\033c" > /dev/tty0