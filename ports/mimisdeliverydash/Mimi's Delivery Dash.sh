#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

# Source PortMaster tools
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

$ESUDO chmod 666 /dev/tty0

# Declare variables
GAMEDIR="/$directory/ports/mimisdeliverydash"

# Exports
export LD_LIBRARY_PATH="/usr/lib:/usr/lib32:/$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"

# Change dir & add config
cd $GAMEDIR

# pack audio into apk if not done yet
if [ -n "$(ls ./gamedata/*.ogg 2>/dev/null)" ]; then
    # Move all .ogg files from ./gamedata to ./assets
    mkdir ./assets
    mv ./gamedata/*.ogg ./assets/
    echo "Moved .ogg files from ./gamedata to ./assets/"

    # Zip the contents of ./MDD.apk including the new .ogg files
    zip -r -0 ./MDD.apk ./assets/
    echo "Zipped contents to ./MDD.apk"
    rm -Rf "$GAMEDIR/assets/"
	
	# Rename data.win
	mv "gamedata/data.win" "gamedata/game.droid"
fi

# Setup controls
$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "gmloader" -c "control.gptk" &
echo "Loading, please wait... " > /dev/tty0

$ESUDO chmod +x "$GAMEDIR/gmloader"

./gmloader MDD.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0

