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

export PORT_32BIT="Y"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

$ESUDO chmod 666 /dev/tty0

GAMEDIR=/$directory/ports/supermegazero

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$GAMEDIR/utils/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"

cd $GAMEDIR

useroptions_file="$GAMEDIR/gamedata/user_options.ini"

sed -i 's/X="[^"]*"/X="'${DISPLAY_WIDTH}'"/' "$useroptions_file"
sed -i 's/Y="[^"]*"/Y="'${DISPLAY_HEIGHT}'"/' "$useroptions_file"

# pack audio into apk if not done yet
if [ -n "$(ls ./gamedata/*.ogg 2>/dev/null)" ]; then
    # Move all .ogg files from ./gamedata to ./assets
    mkdir ./assets
    mv ./gamedata/*.ogg ./assets/
    echo "Moved .ogg files from ./gamedata to ./assets/"

    # Zip the contents of ./supermegazero.apk including the new .ogg files
    zip -r -0 ./supermegazero.apk ./assets/
    echo "Zipped contents to ./supermegazero.apk"
    rm -Rf "$GAMEDIR/assets/"

    # cleanup if extra files were copied in from steam
    rm -Rf $GAMEDIR/gamedata/*.dll $GAMEDIR/gamedata/*.chroma $GAMEDIR/gamedata/*.html $GAMEDIR/gamedata/supermegazero.exe
fi

[ -f "./gamedata/data.win" ] && mv gamedata/data.win gamedata/game.droid
[ -f "./gamedata/game.unx" ] && mv gamedata/game.win gamedata/game.droid

$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "gmloader" &

$ESUDO chmod +x "$GAMEDIR/gmloader"

./gmloader supermegazero.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
