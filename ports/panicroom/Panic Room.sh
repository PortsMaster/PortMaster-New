#!/bin/bash
# PORTMASTER: panicroom.zip, Panic Room.sh

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/device_info.txt
get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

$ESUDO chmod 666 /dev/tty0

GAMEDIR="/$directory/ports/panicroom"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$GAMEDIR/utils/libs"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"

# We log the execution of the script into log.txt
exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Check if PANIC ROOM v1.1.0.exe exists and patch if so
if [ -f "$GAMEDIR/PANIC ROOM v1.1.0.exe" ]; then
   
    # Change directory to the specified directory
    cd "$GAMEDIR" || exit

    # Use 7zip to extract the .exe file to the destination directory
    "$GAMEDIR/patch/7zzs" x "$GAMEDIR/PANIC ROOM v1.1.0.exe" -o"$GAMEDIR/gamedata" & pid=$!

    # Wait for the extraction process to complete
    wait $pid

    # Check if the panicroom.exe file exists
    if [ -f "$GAMEDIR/gamedata/panicroom.exe" ]; then
        # Delete the redundant .exe files
        rm "$GAMEDIR/gamedata/panicroom.exe"
	rm "$GAMEDIR/PANIC ROOM v1.1.0.exe"
    fi
else
    echo "Error: Missing files in gamedata folder!"
fi

cd $GAMEDIR

# Check for file existence before trying to manipulate them:
[ -f "./gamedata/data.win" ] && mv gamedata/data.win gamedata/game.droid
[ -f "./gamedata/game.win" ] && mv gamedata/game.win gamedata/game.droid
[ -f "./gamedata/game.unx" ] && mv gamedata/game.unx gamedata/game.droid

# Make sure uinput is accessible so we can make use of the gptokeyb controls
$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "gmloader" -c ./panicroom.gptk &

$ESUDO chmod +x "$GAMEDIR/gmloader"

./gmloader panicroom.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
