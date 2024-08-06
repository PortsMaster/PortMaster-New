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
$ESUDO chmod 777 "$GAMEDIR/lib/7za"

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

# Run the installer file if it hasn't been run yet
if [ ! -f "$GAMEDIR/installed" ]; then	
    echo "Performing first-run setup..." > $CUR_TTY
	# Redirect output to install.log only for the commands within the if condition
	(
		exec > >(tee -a "$GAMEDIR/install.log") 2>&1
        # Purge unneeded files
        rm -rf assets/*.ini assets/*.exe
		# Rename data.win
        echo "Moving the game file..." > $CUR_TTY
		mv "./assets/data.win" "./game.droid"

		# Create a new zip file game.apk from specified directories
		echo "Zipping assets into apk..." > $CUR_TTY
		./libs/7za a -mx=0 -r "./game.apk" "./assets"
        rm -rf "$GAMEDIR/assets"
	
		# Create 'installed' file to indicate successful installation
		touch "$GAMEDIR/installed"
	)
    if [ -f "utyellow.xdelta" ]; then
    $controlfolder/xdelta3 -d -s "$GAMEDIR/game.droid" "$GAMEDIR/utyellow.xdelta" "$GAMEDIR/game2.droid"
    rm -rf game.droid
    rm -rf utyellow.xdelta
    mv game2.droid game.droid
fi
    echo "Done! Loading game..." > $CUR_TTY
fi

# Assign gptokeyb and load the game
$GPTOKEYB "gmloadernext" -c "control.gptk" &
./gmloadernext game.apk

# Kill processes
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
