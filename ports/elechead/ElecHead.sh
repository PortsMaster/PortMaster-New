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

$ESUDO chmod 666 /dev/tty0

GAMEDIR="/$directory/ports/elechead"

export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/libs:$LD_LIBRARY_PATH"

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Patch game
cd "$GAMEDIR"

# If "gamedata/data.win" exists and matches the checksum of the itch or steam versions
if [ -f "./gamedata/data.win" ]; then
    mv gamedata/data.win gamedata/game.droid
    rm -f "$GAMEDIR/gamedata/ElecHead.exe"
    mv "$GAMEDIR/gamedata"/* "$GAMEDIR" && rm -rf "$GAMEDIR/gamedata" || exit 1
    echo "Moving and Cleaning of game files done"
else    
    echo "Error: Missing files in gamedata folder or game has been patched."
fi

save_file="$GAMEDIR/savefile.sav"

if [ ! -f "$save_file" ]; then
  mv $save_file.default $save_file
fi

if [[ "${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}" == "720x720" ]]; then
sed -i 's/windowScale="[^"]*"/windowScale="1.500000"/' "$save_file"
sed -i 's/isFullscreen="[^"]*"/isFullscreen="0.000000"/' "$save_file"
fi

$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "gmloadernext" &

$ESUDO chmod +x "$GAMEDIR/gmloadernext"
$ESUDO chmod +x "$GAMEDIR/libs/splash"

# Display loading splash
if [ -f "$GAMEDIR/game.droid" ]; then
    $ESUDO ./libs/splash "splash.png" 1 
    $ESUDO ./libs/splash "splash.png" 8000
fi

./gmloadernext game.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0