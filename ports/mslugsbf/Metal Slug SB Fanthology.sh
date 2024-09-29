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

# Echo
echo "Loading port, please wait..." > $CUR_TTY

# Setup permissions
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

# Variables
GAMEDIR="/$directory/ports/mslugsbf"

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO chmod 777 "$GAMEDIR/gmloadernext-armhf"

# Exports
export LD_LIBRARY_PATH="/usr/lib:/usr/lib32:/$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_PLATFORM="os_windows"
export PORT_32BIT="Y"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

install-win() {
    if [ ! -f "$GAMEDIR/installed" ]; then	
        echo "Performing first-run setup..." > $CUR_TTY
        # Purge unneeded files
        rm -rf assets/*.ini assets/*.exe assets/*.dll assets/*.png || exit 1
        # Rename data.win
        echo "Moving the game file..." > $CUR_TTY
        mv "./assets/data.win" "./game.droid" || exit 1
        # Create a new zip file game.apk from specified directories
        echo "Zipping assets into apk..." > $CUR_TTY
        ./utils/zip -r -0 "game.apk" "assets" || exit 1
        # Remove assets directory
        rm -rf "$GAMEDIR/assets" || exit 1
        # Mark installation as complete
        touch "$GAMEDIR/installed"
    fi
}

if [ ! -f "$GAMEDIR/installed" ]; then
    install-win
fi

# Assign gptokeyb and load the game
$GPTOKEYB "gmloadernext-armhf" -c "control.gptk" &
./gmloadernext-armhf game.apk

# Kill processes
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
