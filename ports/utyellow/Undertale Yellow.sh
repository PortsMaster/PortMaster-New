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
echo "Loading, please wait... (might take a while!)" > /dev/tty0

# Variables
GAMEDIR="/$directory/ports/utyellow"
CUR_TTY="/dev/tty0"

# Set current virtual screen
if [ "$CFW_NAME" == "muOS" ]; then
  /opt/muos/extra/muxlog & CUR_TTY="/tmp/muxlog_info"
else
    CUR_TTY="/dev/tty0"
fi

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO chmod 777 "$GAMEDIR/gmloadernext"

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

# Run the installer file if it hasn't been run yet
install-apk() {
    if [ ! -f "$GAMEDIR/installed" ]; then
        echo "Performing first-run setup..." > $CUR_TTY
        PATCHFILE="patch-droid.xdelta"
        # Extract the APK, replace game.droid, and repack
        mkdir -p "$GAMEDIR/assets"
        ./utils/unzip "yellow.apk" -d "$GAMEDIR/assets/"
        mv "$GAMEDIR/assets/assets/game.droid" "$GAMEDIR/game.droid"
        apply_patch
        mv "$GAMEDIR/game.droid" "$GAMEDIR/assets/assets/game.droid"
        ./utils/zip -r -0 "yellow.apk" "assets"
        rm -rf "$GAMEDIR/assets"
        rm -rf game.apk
        mv yellow.apk game.apk
        touch "$GAMEDIR/installed"
    fi
}
install-win() {
    if [ ! -f "$GAMEDIR/installed" ]; then	
        echo "Performing first-run setup..." > $CUR_TTY
        PATCHFILE="patch-win.xdelta"
        # Purge unneeded files
        rm -rf assets/*.ini assets/*.exe
        # Rename data.win
        echo "Moving the game file..." > $CUR_TTY
        mv "./assets/data.win" "./game.droid"
        # Create a new zip file game.apk from specified directories
        echo "Zipping assets into apk..." > $CUR_TTY
        ./utils/zip -r -0 "game.apk" "assets"
        rm -rf "$GAMEDIR/assets"
        apply_patch
    fi
}
apply_patch() {
    if [ -f "$PATCHFILE" ]; then
        echo "Applying patch..." > $CUR_TTY
        $controlfolder/xdelta3 -d -s "$GAMEDIR/game.droid" "$GAMEDIR/$PATCHFILE" "$GAMEDIR/game2.droid"
        rm -rf game.droid
        rm -rf *.xdelta
        mv game2.droid game.droid
    fi
}

if [ -f "$GAMEDIR/yellow.apk" ]; then
    install-apk
else
    install-win
fi

# Assign gptokeyb and load the game
$GPTOKEYB "gmloadernext" -c "control.gptk" &
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
./gmloadernext game.apk

# Kill processes
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
